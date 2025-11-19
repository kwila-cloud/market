-- RLS policies that depend on tables defined in other files
-- These must run after all referenced tables are created

-- Contact info: connections-only visibility requires connection table
create policy "Users can view connections-only contact info of connections"
    on contact_info for select
    to authenticated
    using (
        visibility = 'connections-only'
        and exists (
            select 1 from connection
            where status = 'accepted'
            and (
                (user_a = auth.uid() and user_b = contact_info.user_id)
                or (user_b = auth.uid() and user_a = contact_info.user_id)
            )
        )
    );

-- Item: connections-only visibility requires connection table
create policy "Users can view connections-only items from connections"
    on item for select
    to authenticated
    using (
        visibility = 'connections-only'
        and status != 'deleted'
        and exists (
            select 1 from connection
            where status = 'accepted'
            and (
                (user_a = auth.uid() and user_b = item.user_id)
                or (user_b = auth.uid() and user_a = item.user_id)
            )
        )
    );

-- Item images: connections-only visibility requires connection table
create policy "Users can view connections-only item images from connections"
    on item_image for select
    to authenticated
    using (
        exists (
            select 1 from item
            where item.id = item_image.item_id
            and item.visibility = 'connections-only'
            and item.status != 'deleted'
            and exists (
                select 1 from connection
                where status = 'accepted'
                and (
                    (user_a = auth.uid() and user_b = item.user_id)
                    or (user_b = auth.uid() and user_a = item.user_id)
                )
            )
        )
    );
