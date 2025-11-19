-- RLS policies that depend on tables defined in other files
-- These must run after all referenced tables are created

-- Contact info: combined SELECT policy for authenticated users
-- Combines: own, public, and connections-only visibility
create policy "Users can view contact info"
    on contact_info for select
    to authenticated
    using (
        user_id = (select auth.uid())
        or visibility = 'public'
        or (
            visibility = 'connections-only'
            and exists (
                select 1 from connection
                where status = 'accepted'
                and (
                    (user_a = (select auth.uid()) and user_b = contact_info.user_id)
                    or (user_b = (select auth.uid()) and user_a = contact_info.user_id)
                )
            )
        )
    );

-- Item: combined SELECT policy for authenticated users
-- Combines: own, public, and connections-only visibility
create policy "Users can view items"
    on item for select
    to authenticated
    using (
        user_id = (select auth.uid())
        or (visibility = 'public' and status != 'deleted')
        or (
            visibility = 'connections-only'
            and status != 'deleted'
            and exists (
                select 1 from connection
                where status = 'accepted'
                and (
                    (user_a = (select auth.uid()) and user_b = item.user_id)
                    or (user_b = (select auth.uid()) and user_a = item.user_id)
                )
            )
        )
    );

-- Item images: combined SELECT policy for authenticated users
-- Combines: own, public, and connections-only visibility
create policy "Users can view item images"
    on item_image for select
    to authenticated
    using (
        exists (
            select 1 from item
            where item.id = item_image.item_id
            and (
                item.user_id = (select auth.uid())
                or (item.visibility = 'public' and item.status != 'deleted')
                or (
                    item.visibility = 'connections-only'
                    and item.status != 'deleted'
                    and exists (
                        select 1 from connection
                        where status = 'accepted'
                        and (
                            (user_a = (select auth.uid()) and user_b = item.user_id)
                            or (user_b = (select auth.uid()) and user_a = item.user_id)
                        )
                    )
                )
            )
        )
    );
