-- Auth triggers for automatic user creation
-- Creates a public user record when a new auth user is created

-- Function to handle new auth user creation
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer set search_path = ''
as $$
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
$$;

-- Trigger that fires after a new auth user is created
create trigger on_auth_user_created
    after insert on auth.users
    for each row execute function public.handle_new_user();

-- Grant necessary permissions
grant usage on schema public to supabase_auth_admin;
grant all on public."user" to supabase_auth_admin;
grant all on public.contact_info to supabase_auth_admin;
