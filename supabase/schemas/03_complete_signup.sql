-- Complete signup function and auth_user_id column
-- Replaces the automatic user creation trigger with manual signup completion

-- Add auth_user_id column to user table
-- This explicitly tracks which auth.users record owns each user profile
alter table "user" add column if not exists auth_user_id uuid unique not null references auth.users(id) on delete cascade;

-- Create index for performance
create index if not exists idx_user_auth_user_id on "user"(auth_user_id);

-- Helper function to get user by auth ID
-- Useful for RLS policies and API endpoints
create or replace function public.get_user_by_auth_id(p_auth_user_id uuid)
returns uuid
language sql
security definer
stable
set search_path = ''
as $$
  select id from public."user" where auth_user_id = p_auth_user_id;
$$;

-- Grant execute to authenticated users
grant execute on function public.get_user_by_auth_id(uuid) to authenticated;

-- Add comment for documentation
comment on function public.get_user_by_auth_id is
  'Returns the user.id for a given auth.users.id. Returns null if no user profile exists.';

-- Function to validate invite codes for new users
-- Bypasses RLS so new authenticated users (without profiles) can check invite validity
-- TODO: Consider adding Terraform-based Cloudflare rate limiting for production if brute force becomes a concern
create or replace function public.validate_invite_code(p_invite_code text)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_invite_record record;
begin
  -- Rate limiting: 5 second delay to prevent brute force attacks
  -- With 2.8 trillion possible codes, this makes brute forcing impractical
  perform pg_sleep(5);

  -- Validate and fetch invite code
  select * into v_invite_record
  from public.invite
  where invite_code = upper(p_invite_code)
    and used_at is null
    and revoked_at is null;

  if not found then
    return jsonb_build_object(
      'valid', false,
      'error', 'Invalid or already used invite code'
    );
  end if;

  -- Valid invite code
  return jsonb_build_object(
    'valid', true,
    'name', v_invite_record.name
  );
end;
$$;

-- Grant execute to authenticated users
grant execute on function public.validate_invite_code(text) to authenticated;

-- Add comment for documentation
comment on function public.validate_invite_code is
  'Validates an invite code for new users. Includes 5-second delay for brute force protection. Returns validation status and invitee name if valid.';

-- Function to complete user signup after OTP verification
-- Called from the frontend after onboarding wizard is complete
create or replace function public.complete_signup(
  p_invite_code text,
  p_display_name text,
  p_about text,
  p_contact_visibility visibility
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_auth_user_id uuid;
  v_invite_record record;
  v_new_user_id uuid;
  v_avatar_url text;
begin
  -- Get the authenticated user's ID
  v_auth_user_id := auth.uid();

  -- Security check: must be authenticated
  if v_auth_user_id is null then
    raise exception 'Not authenticated';
  end if;

  -- Security check: user must not already have a profile
  if get_user_by_auth_id(v_auth_user_id) is not null then
    raise exception 'User profile already exists';
  end if;

  -- Validate and fetch invite code
  select * into v_invite_record
  from public.invite
  where invite_code = p_invite_code
    and used_at is null
    and revoked_at is null;

  if not found then
    raise exception 'Invalid or already used invite code';
  end if;

  -- Generate avatar URL using dicebear API with initials style
  -- Extract initials from display name (first letter of first two words)
  v_avatar_url := 'https://api.dicebear.com/7.x/initials/svg?seed=' ||
    encode(p_display_name::bytea, 'base64');

  -- Create user record
  -- id = auth_user_id for consistency with existing RLS policies
  insert into public."user" (
    id,
    auth_user_id,
    display_name,
    about,
    avatar_url,
    invited_by
  )
  values (
    v_auth_user_id,
    v_auth_user_id,
    p_display_name,
    p_about,
    v_avatar_url,
    v_invite_record.inviter_id
  )
  returning id into v_new_user_id;

  -- Create contact info with user's auth email or phone
  -- Get from auth.users table
  insert into public.contact_info (user_id, contact_type, value, visibility)
  select
    v_new_user_id,
    case
      when au.email is not null then 'email'::contact_type
      when au.phone is not null then 'phone'::contact_type
    end,
    coalesce(au.email, au.phone),
    p_contact_visibility
  from auth.users au
  where au.id = v_auth_user_id
    and (au.email is not null or au.phone is not null);

  -- Create bidirectional connection between inviter and new user
  -- inviter → new user (accepted)
  insert into public.connection (user_a, user_b, status)
  values (v_invite_record.inviter_id, v_new_user_id, 'accepted');

  -- Mark invite as used
  update public.invite
  set used_by = v_new_user_id,
      used_at = now()
  where id = v_invite_record.id;

  -- Return success with user data
  return jsonb_build_object(
    'success', true,
    'user_id', v_new_user_id,
    'display_name', p_display_name,
    'avatar_url', v_avatar_url
  );

exception
  when others then
    -- Log error for debugging but return generic message
    raise notice 'Signup error: %', SQLERRM;
    raise exception 'Failed to complete signup. Please try again.';
end;
$$;

-- Grant execute permission to authenticated users
grant execute on function public.complete_signup(text, text, text, visibility) to authenticated;

-- Add comment for documentation
comment on function public.complete_signup is
  'Completes user signup after OTP verification. Creates user profile, establishes connection with inviter, and marks invite as used. Must be called by authenticated user without existing profile.';
