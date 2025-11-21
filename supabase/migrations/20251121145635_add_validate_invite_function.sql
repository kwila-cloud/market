set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.validate_invite_code(p_invite_code text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
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
$function$
;
