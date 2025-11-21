set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.complete_signup(p_invite_code text, p_display_name text, p_about text, p_contact_visibility public.visibility)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  v_auth_user_id uuid;
  v_invite_record record;
  v_new_user_id uuid;
  v_avatar_url text;
begin
  -- Rate limiting: 5 second delay to prevent brute force attacks
  -- This prevents attackers from bypassing validate_invite_code() and calling complete_signup() directly
  perform pg_sleep(5);

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
$function$
;
