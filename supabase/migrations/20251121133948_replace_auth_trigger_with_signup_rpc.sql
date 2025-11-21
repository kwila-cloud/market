-- Drop the trigger first (before the function it depends on)
drop trigger if exists "on_auth_user_created" on "auth"."users";

-- Now drop the function
drop function if exists "public"."handle_new_user"();

-- Revoke permissions that were granted to supabase_auth_admin
revoke delete on table "public"."contact_info" from "supabase_auth_admin";

revoke insert on table "public"."contact_info" from "supabase_auth_admin";

revoke references on table "public"."contact_info" from "supabase_auth_admin";

revoke select on table "public"."contact_info" from "supabase_auth_admin";

revoke trigger on table "public"."contact_info" from "supabase_auth_admin";

revoke truncate on table "public"."contact_info" from "supabase_auth_admin";

revoke update on table "public"."contact_info" from "supabase_auth_admin";

revoke delete on table "public"."user" from "supabase_auth_admin";

revoke insert on table "public"."user" from "supabase_auth_admin";

revoke references on table "public"."user" from "supabase_auth_admin";

revoke select on table "public"."user" from "supabase_auth_admin";

revoke trigger on table "public"."user" from "supabase_auth_admin";

revoke truncate on table "public"."user" from "supabase_auth_admin";

revoke update on table "public"."user" from "supabase_auth_admin";

alter table "public"."user" add column "auth_user_id" uuid not null;

CREATE INDEX idx_user_auth_user_id ON public."user" USING btree (auth_user_id);

CREATE UNIQUE INDEX user_auth_user_id_key ON public."user" USING btree (auth_user_id);

alter table "public"."user" add constraint "user_auth_user_id_fkey" FOREIGN KEY (auth_user_id) REFERENCES auth.users(id) ON DELETE CASCADE not valid;

alter table "public"."user" validate constraint "user_auth_user_id_fkey";

alter table "public"."user" add constraint "user_auth_user_id_key" UNIQUE using index "user_auth_user_id_key";

set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.get_user_by_auth_id(p_auth_user_id uuid)
 RETURNS uuid
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
  select id from public."user" where auth_user_id = p_auth_user_id;
$function$
;

grant execute on function public.get_user_by_auth_id(uuid) to authenticated;

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

grant execute on function public.complete_signup(text, text, text, public.visibility) to authenticated;
