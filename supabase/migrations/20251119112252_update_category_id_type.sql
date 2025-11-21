-- Drop foreign key constraint first
alter table "public"."item" drop constraint "item_category_id_fkey";

-- Drop primary key constraint (this also drops the underlying index)
alter table "public"."category" drop constraint if exists "category_pkey";

-- Drop the index on item.category_id
drop index if exists "public"."idx_item_category_id";

-- Change column types
alter table "public"."category" alter column "id" drop default;
alter table "public"."category" alter column "id" set data type text using "id"::text;
alter table "public"."item" alter column "category_id" set data type text using "category_id"::text;

-- Recreate primary key constraint
alter table "public"."category" add constraint "category_pkey" primary key ("id");

-- Recreate index on item.category_id
CREATE INDEX idx_item_category_id ON public.item USING btree (category_id);

-- Recreate foreign key constraint
alter table "public"."item" add constraint "item_category_id_fkey" FOREIGN KEY (category_id) REFERENCES public.category(id) not valid;

alter table "public"."item" validate constraint "item_category_id_fkey";
