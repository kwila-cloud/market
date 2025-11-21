set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.can_create_invite(user_id uuid)
 RETURNS boolean
 LANGUAGE sql
 STABLE SECURITY DEFINER
AS $function$
    select not exists (
        select 1
        from invite
        where inviter_id = user_id
            and revoked_at is null
            and created_at > now() - interval '24 hours'
    );
$function$
;
