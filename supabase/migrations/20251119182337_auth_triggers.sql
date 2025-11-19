-- Auth triggers for automatic user creation
-- Creates a public user record when a new auth user is created

set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.handle_new_user()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
begin
    -- Create a basic user record with auth user's id
    -- Display name defaults to email username or 'New User'
    insert into public."user" (id, display_name)
    values (
        new.id,
        coalesce(
            split_part(new.email, '@', 1),
            'New User'
        )
    );

    -- Create hidden contact info with auth email
    if new.email is not null then
        insert into public.contact_info (user_id, contact_type, value, visibility)
        values (new.id, 'email', new.email, 'hidden');
    end if;

    return new;
end;
$function$
;

-- Grant necessary permissions to auth admin
grant delete on table "public"."contact_info" to "supabase_auth_admin";
grant insert on table "public"."contact_info" to "supabase_auth_admin";
grant references on table "public"."contact_info" to "supabase_auth_admin";
grant select on table "public"."contact_info" to "supabase_auth_admin";
grant trigger on table "public"."contact_info" to "supabase_auth_admin";
grant truncate on table "public"."contact_info" to "supabase_auth_admin";
grant update on table "public"."contact_info" to "supabase_auth_admin";

grant delete on table "public"."user" to "supabase_auth_admin";
grant insert on table "public"."user" to "supabase_auth_admin";
grant references on table "public"."user" to "supabase_auth_admin";
grant select on table "public"."user" to "supabase_auth_admin";
grant trigger on table "public"."user" to "supabase_auth_admin";
grant truncate on table "public"."user" to "supabase_auth_admin";
grant update on table "public"."user" to "supabase_auth_admin";

-- Trigger that fires after a new auth user is created
CREATE TRIGGER on_auth_user_created AFTER INSERT ON auth.users FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();
