create type "public"."connection_status" as enum ('pending', 'accepted', 'declined');

create type "public"."contact_type" as enum ('email', 'phone');

create type "public"."item_status" as enum ('active', 'archived', 'deleted');

create type "public"."item_type" as enum ('buy', 'sell');

create type "public"."visibility" as enum ('hidden', 'connections-only', 'public');


  create table "public"."category" (
    "id" uuid not null default extensions.uuid_generate_v4(),
    "name" text not null,
    "description" text,
    "created_at" timestamp with time zone not null default now()
      );


alter table "public"."category" enable row level security;


  create table "public"."connection" (
    "id" uuid not null default extensions.uuid_generate_v4(),
    "user_a" uuid not null,
    "user_b" uuid not null,
    "status" public.connection_status not null default 'pending'::public.connection_status,
    "created_at" timestamp with time zone not null default now()
      );


alter table "public"."connection" enable row level security;


  create table "public"."contact_info" (
    "id" uuid not null default extensions.uuid_generate_v4(),
    "user_id" uuid not null,
    "contact_type" public.contact_type not null,
    "value" text not null,
    "visibility" public.visibility not null default 'hidden'::public.visibility,
    "created_at" timestamp with time zone not null default now()
      );


alter table "public"."contact_info" enable row level security;


  create table "public"."invite" (
    "id" uuid not null default extensions.uuid_generate_v4(),
    "inviter_id" uuid not null,
    "invite_code" text not null,
    "used_by" uuid,
    "used_at" timestamp with time zone,
    "revoked_at" timestamp with time zone,
    "created_at" timestamp with time zone not null default now()
      );


alter table "public"."invite" enable row level security;


  create table "public"."item" (
    "id" uuid not null default extensions.uuid_generate_v4(),
    "user_id" uuid not null,
    "type" public.item_type not null,
    "category_id" uuid not null,
    "title" text not null,
    "description" text,
    "price_string" text,
    "visibility" public.visibility not null default 'public'::public.visibility,
    "status" public.item_status not null default 'active'::public.item_status,
    "created_at" timestamp with time zone not null default now(),
    "updated_at" timestamp with time zone not null default now()
      );


alter table "public"."item" enable row level security;


  create table "public"."item_image" (
    "id" uuid not null default extensions.uuid_generate_v4(),
    "item_id" uuid not null,
    "url" text not null,
    "alt_text" text,
    "order_index" integer not null default 0,
    "created_at" timestamp with time zone not null default now()
      );


alter table "public"."item_image" enable row level security;


  create table "public"."message" (
    "id" uuid not null default extensions.uuid_generate_v4(),
    "thread_id" uuid not null,
    "sender_id" uuid not null,
    "content" text not null,
    "read" boolean not null default false,
    "created_at" timestamp with time zone not null default now()
      );


alter table "public"."message" enable row level security;


  create table "public"."message_image" (
    "id" uuid not null default extensions.uuid_generate_v4(),
    "message_id" uuid not null,
    "url" text not null,
    "order_index" integer not null default 0,
    "created_at" timestamp with time zone not null default now()
      );


alter table "public"."message_image" enable row level security;


  create table "public"."thread" (
    "id" uuid not null default extensions.uuid_generate_v4(),
    "item_id" uuid not null,
    "creator_id" uuid not null,
    "responder_id" uuid not null,
    "created_at" timestamp with time zone not null default now()
      );


alter table "public"."thread" enable row level security;


  create table "public"."user" (
    "id" uuid not null default extensions.uuid_generate_v4(),
    "display_name" text not null,
    "about" text,
    "avatar_url" text,
    "vendor_id" text,
    "created_at" timestamp with time zone not null default now(),
    "invited_by" uuid
      );


alter table "public"."user" enable row level security;


  create table "public"."user_settings" (
    "id" uuid not null default extensions.uuid_generate_v4(),
    "user_id" uuid not null,
    "setting_key" text not null,
    "setting_value" jsonb not null default '{}'::jsonb,
    "created_at" timestamp with time zone not null default now(),
    "updated_at" timestamp with time zone not null default now()
      );


alter table "public"."user_settings" enable row level security;


  create table "public"."watch" (
    "id" uuid not null default extensions.uuid_generate_v4(),
    "user_id" uuid not null,
    "name" text not null,
    "query_params" text not null,
    "notify" uuid,
    "created_at" timestamp with time zone not null default now()
      );


alter table "public"."watch" enable row level security;

CREATE UNIQUE INDEX category_name_key ON public.category USING btree (name);

CREATE UNIQUE INDEX category_pkey ON public.category USING btree (id);

CREATE UNIQUE INDEX connection_pkey ON public.connection USING btree (id);

CREATE UNIQUE INDEX connection_user_a_user_b_key ON public.connection USING btree (user_a, user_b);

CREATE UNIQUE INDEX contact_info_pkey ON public.contact_info USING btree (id);

CREATE INDEX idx_connection_accepted ON public.connection USING btree (user_a, user_b) WHERE (status = 'accepted'::public.connection_status);

CREATE INDEX idx_connection_status ON public.connection USING btree (status);

CREATE INDEX idx_connection_user_a ON public.connection USING btree (user_a);

CREATE INDEX idx_connection_user_b ON public.connection USING btree (user_b);

CREATE INDEX idx_contact_info_user_id ON public.contact_info USING btree (user_id);

CREATE INDEX idx_contact_info_visibility ON public.contact_info USING btree (visibility);

CREATE INDEX idx_invite_available ON public.invite USING btree (invite_code) WHERE ((used_by IS NULL) AND (revoked_at IS NULL));

CREATE INDEX idx_invite_code ON public.invite USING btree (invite_code);

CREATE INDEX idx_invite_inviter_id ON public.invite USING btree (inviter_id);

CREATE INDEX idx_item_category_id ON public.item USING btree (category_id);

CREATE INDEX idx_item_created_at ON public.item USING btree (created_at DESC);

CREATE INDEX idx_item_feed ON public.item USING btree (visibility, status, type, created_at DESC);

CREATE INDEX idx_item_image_item_id ON public.item_image USING btree (item_id);

CREATE INDEX idx_item_image_order ON public.item_image USING btree (item_id, order_index);

CREATE INDEX idx_item_status ON public.item USING btree (status);

CREATE INDEX idx_item_type ON public.item USING btree (type);

CREATE INDEX idx_item_user_id ON public.item USING btree (user_id);

CREATE INDEX idx_item_visibility ON public.item USING btree (visibility);

CREATE INDEX idx_message_created_at ON public.message USING btree (created_at DESC);

CREATE INDEX idx_message_image_message_id ON public.message_image USING btree (message_id);

CREATE INDEX idx_message_sender_id ON public.message USING btree (sender_id);

CREATE INDEX idx_message_thread_id ON public.message USING btree (thread_id);

CREATE INDEX idx_message_unread ON public.message USING btree (thread_id, read) WHERE (read = false);

CREATE INDEX idx_thread_creator_id ON public.thread USING btree (creator_id);

CREATE INDEX idx_thread_item_id ON public.thread USING btree (item_id);

CREATE INDEX idx_thread_responder_id ON public.thread USING btree (responder_id);

CREATE INDEX idx_user_invited_by ON public."user" USING btree (invited_by);

CREATE INDEX idx_user_settings_user_id ON public.user_settings USING btree (user_id);

CREATE INDEX idx_user_vendor_id ON public."user" USING btree (vendor_id) WHERE (vendor_id IS NOT NULL);

CREATE INDEX idx_watch_user_id ON public.watch USING btree (user_id);

CREATE UNIQUE INDEX invite_invite_code_key ON public.invite USING btree (invite_code);

CREATE UNIQUE INDEX invite_pkey ON public.invite USING btree (id);

CREATE UNIQUE INDEX item_image_pkey ON public.item_image USING btree (id);

CREATE UNIQUE INDEX item_pkey ON public.item USING btree (id);

CREATE UNIQUE INDEX message_image_pkey ON public.message_image USING btree (id);

CREATE UNIQUE INDEX message_pkey ON public.message USING btree (id);

CREATE UNIQUE INDEX thread_item_id_creator_id_responder_id_key ON public.thread USING btree (item_id, creator_id, responder_id);

CREATE UNIQUE INDEX thread_pkey ON public.thread USING btree (id);

CREATE UNIQUE INDEX user_pkey ON public."user" USING btree (id);

CREATE UNIQUE INDEX user_settings_pkey ON public.user_settings USING btree (id);

CREATE UNIQUE INDEX user_settings_user_id_setting_key_key ON public.user_settings USING btree (user_id, setting_key);

CREATE UNIQUE INDEX user_vendor_id_key ON public."user" USING btree (vendor_id);

CREATE UNIQUE INDEX watch_pkey ON public.watch USING btree (id);

alter table "public"."category" add constraint "category_pkey" PRIMARY KEY using index "category_pkey";

alter table "public"."connection" add constraint "connection_pkey" PRIMARY KEY using index "connection_pkey";

alter table "public"."contact_info" add constraint "contact_info_pkey" PRIMARY KEY using index "contact_info_pkey";

alter table "public"."invite" add constraint "invite_pkey" PRIMARY KEY using index "invite_pkey";

alter table "public"."item" add constraint "item_pkey" PRIMARY KEY using index "item_pkey";

alter table "public"."item_image" add constraint "item_image_pkey" PRIMARY KEY using index "item_image_pkey";

alter table "public"."message" add constraint "message_pkey" PRIMARY KEY using index "message_pkey";

alter table "public"."message_image" add constraint "message_image_pkey" PRIMARY KEY using index "message_image_pkey";

alter table "public"."thread" add constraint "thread_pkey" PRIMARY KEY using index "thread_pkey";

alter table "public"."user" add constraint "user_pkey" PRIMARY KEY using index "user_pkey";

alter table "public"."user_settings" add constraint "user_settings_pkey" PRIMARY KEY using index "user_settings_pkey";

alter table "public"."watch" add constraint "watch_pkey" PRIMARY KEY using index "watch_pkey";

alter table "public"."category" add constraint "category_name_key" UNIQUE using index "category_name_key";

alter table "public"."connection" add constraint "connection_check" CHECK ((user_a <> user_b)) not valid;

alter table "public"."connection" validate constraint "connection_check";

alter table "public"."connection" add constraint "connection_user_a_fkey" FOREIGN KEY (user_a) REFERENCES public."user"(id) ON DELETE CASCADE not valid;

alter table "public"."connection" validate constraint "connection_user_a_fkey";

alter table "public"."connection" add constraint "connection_user_a_user_b_key" UNIQUE using index "connection_user_a_user_b_key";

alter table "public"."connection" add constraint "connection_user_b_fkey" FOREIGN KEY (user_b) REFERENCES public."user"(id) ON DELETE CASCADE not valid;

alter table "public"."connection" validate constraint "connection_user_b_fkey";

alter table "public"."contact_info" add constraint "contact_info_user_id_fkey" FOREIGN KEY (user_id) REFERENCES public."user"(id) ON DELETE CASCADE not valid;

alter table "public"."contact_info" validate constraint "contact_info_user_id_fkey";

alter table "public"."invite" add constraint "invite_invite_code_key" UNIQUE using index "invite_invite_code_key";

alter table "public"."invite" add constraint "invite_inviter_id_fkey" FOREIGN KEY (inviter_id) REFERENCES public."user"(id) ON DELETE CASCADE not valid;

alter table "public"."invite" validate constraint "invite_inviter_id_fkey";

alter table "public"."invite" add constraint "invite_used_by_fkey" FOREIGN KEY (used_by) REFERENCES public."user"(id) not valid;

alter table "public"."invite" validate constraint "invite_used_by_fkey";

alter table "public"."item" add constraint "item_category_id_fkey" FOREIGN KEY (category_id) REFERENCES public.category(id) not valid;

alter table "public"."item" validate constraint "item_category_id_fkey";

alter table "public"."item" add constraint "item_user_id_fkey" FOREIGN KEY (user_id) REFERENCES public."user"(id) ON DELETE CASCADE not valid;

alter table "public"."item" validate constraint "item_user_id_fkey";

alter table "public"."item_image" add constraint "item_image_item_id_fkey" FOREIGN KEY (item_id) REFERENCES public.item(id) ON DELETE CASCADE not valid;

alter table "public"."item_image" validate constraint "item_image_item_id_fkey";

alter table "public"."message" add constraint "message_sender_id_fkey" FOREIGN KEY (sender_id) REFERENCES public."user"(id) ON DELETE CASCADE not valid;

alter table "public"."message" validate constraint "message_sender_id_fkey";

alter table "public"."message" add constraint "message_thread_id_fkey" FOREIGN KEY (thread_id) REFERENCES public.thread(id) ON DELETE CASCADE not valid;

alter table "public"."message" validate constraint "message_thread_id_fkey";

alter table "public"."message_image" add constraint "message_image_message_id_fkey" FOREIGN KEY (message_id) REFERENCES public.message(id) ON DELETE CASCADE not valid;

alter table "public"."message_image" validate constraint "message_image_message_id_fkey";

alter table "public"."thread" add constraint "thread_check" CHECK ((creator_id <> responder_id)) not valid;

alter table "public"."thread" validate constraint "thread_check";

alter table "public"."thread" add constraint "thread_creator_id_fkey" FOREIGN KEY (creator_id) REFERENCES public."user"(id) ON DELETE CASCADE not valid;

alter table "public"."thread" validate constraint "thread_creator_id_fkey";

alter table "public"."thread" add constraint "thread_item_id_creator_id_responder_id_key" UNIQUE using index "thread_item_id_creator_id_responder_id_key";

alter table "public"."thread" add constraint "thread_item_id_fkey" FOREIGN KEY (item_id) REFERENCES public.item(id) ON DELETE CASCADE not valid;

alter table "public"."thread" validate constraint "thread_item_id_fkey";

alter table "public"."thread" add constraint "thread_responder_id_fkey" FOREIGN KEY (responder_id) REFERENCES public."user"(id) ON DELETE CASCADE not valid;

alter table "public"."thread" validate constraint "thread_responder_id_fkey";

alter table "public"."user" add constraint "user_invited_by_fkey" FOREIGN KEY (invited_by) REFERENCES public."user"(id) not valid;

alter table "public"."user" validate constraint "user_invited_by_fkey";

alter table "public"."user" add constraint "user_vendor_id_key" UNIQUE using index "user_vendor_id_key";

alter table "public"."user_settings" add constraint "user_settings_user_id_fkey" FOREIGN KEY (user_id) REFERENCES public."user"(id) ON DELETE CASCADE not valid;

alter table "public"."user_settings" validate constraint "user_settings_user_id_fkey";

alter table "public"."user_settings" add constraint "user_settings_user_id_setting_key_key" UNIQUE using index "user_settings_user_id_setting_key_key";

alter table "public"."watch" add constraint "watch_notify_fkey" FOREIGN KEY (notify) REFERENCES public.contact_info(id) not valid;

alter table "public"."watch" validate constraint "watch_notify_fkey";

alter table "public"."watch" add constraint "watch_user_id_fkey" FOREIGN KEY (user_id) REFERENCES public."user"(id) ON DELETE CASCADE not valid;

alter table "public"."watch" validate constraint "watch_user_id_fkey";

grant delete on table "public"."category" to "anon";

grant insert on table "public"."category" to "anon";

grant references on table "public"."category" to "anon";

grant select on table "public"."category" to "anon";

grant trigger on table "public"."category" to "anon";

grant truncate on table "public"."category" to "anon";

grant update on table "public"."category" to "anon";

grant delete on table "public"."category" to "authenticated";

grant insert on table "public"."category" to "authenticated";

grant references on table "public"."category" to "authenticated";

grant select on table "public"."category" to "authenticated";

grant trigger on table "public"."category" to "authenticated";

grant truncate on table "public"."category" to "authenticated";

grant update on table "public"."category" to "authenticated";

grant delete on table "public"."category" to "service_role";

grant insert on table "public"."category" to "service_role";

grant references on table "public"."category" to "service_role";

grant select on table "public"."category" to "service_role";

grant trigger on table "public"."category" to "service_role";

grant truncate on table "public"."category" to "service_role";

grant update on table "public"."category" to "service_role";

grant delete on table "public"."connection" to "anon";

grant insert on table "public"."connection" to "anon";

grant references on table "public"."connection" to "anon";

grant select on table "public"."connection" to "anon";

grant trigger on table "public"."connection" to "anon";

grant truncate on table "public"."connection" to "anon";

grant update on table "public"."connection" to "anon";

grant delete on table "public"."connection" to "authenticated";

grant insert on table "public"."connection" to "authenticated";

grant references on table "public"."connection" to "authenticated";

grant select on table "public"."connection" to "authenticated";

grant trigger on table "public"."connection" to "authenticated";

grant truncate on table "public"."connection" to "authenticated";

grant update on table "public"."connection" to "authenticated";

grant delete on table "public"."connection" to "service_role";

grant insert on table "public"."connection" to "service_role";

grant references on table "public"."connection" to "service_role";

grant select on table "public"."connection" to "service_role";

grant trigger on table "public"."connection" to "service_role";

grant truncate on table "public"."connection" to "service_role";

grant update on table "public"."connection" to "service_role";

grant delete on table "public"."contact_info" to "anon";

grant insert on table "public"."contact_info" to "anon";

grant references on table "public"."contact_info" to "anon";

grant select on table "public"."contact_info" to "anon";

grant trigger on table "public"."contact_info" to "anon";

grant truncate on table "public"."contact_info" to "anon";

grant update on table "public"."contact_info" to "anon";

grant delete on table "public"."contact_info" to "authenticated";

grant insert on table "public"."contact_info" to "authenticated";

grant references on table "public"."contact_info" to "authenticated";

grant select on table "public"."contact_info" to "authenticated";

grant trigger on table "public"."contact_info" to "authenticated";

grant truncate on table "public"."contact_info" to "authenticated";

grant update on table "public"."contact_info" to "authenticated";

grant delete on table "public"."contact_info" to "service_role";

grant insert on table "public"."contact_info" to "service_role";

grant references on table "public"."contact_info" to "service_role";

grant select on table "public"."contact_info" to "service_role";

grant trigger on table "public"."contact_info" to "service_role";

grant truncate on table "public"."contact_info" to "service_role";

grant update on table "public"."contact_info" to "service_role";

grant delete on table "public"."invite" to "anon";

grant insert on table "public"."invite" to "anon";

grant references on table "public"."invite" to "anon";

grant select on table "public"."invite" to "anon";

grant trigger on table "public"."invite" to "anon";

grant truncate on table "public"."invite" to "anon";

grant update on table "public"."invite" to "anon";

grant delete on table "public"."invite" to "authenticated";

grant insert on table "public"."invite" to "authenticated";

grant references on table "public"."invite" to "authenticated";

grant select on table "public"."invite" to "authenticated";

grant trigger on table "public"."invite" to "authenticated";

grant truncate on table "public"."invite" to "authenticated";

grant update on table "public"."invite" to "authenticated";

grant delete on table "public"."invite" to "service_role";

grant insert on table "public"."invite" to "service_role";

grant references on table "public"."invite" to "service_role";

grant select on table "public"."invite" to "service_role";

grant trigger on table "public"."invite" to "service_role";

grant truncate on table "public"."invite" to "service_role";

grant update on table "public"."invite" to "service_role";

grant delete on table "public"."item" to "anon";

grant insert on table "public"."item" to "anon";

grant references on table "public"."item" to "anon";

grant select on table "public"."item" to "anon";

grant trigger on table "public"."item" to "anon";

grant truncate on table "public"."item" to "anon";

grant update on table "public"."item" to "anon";

grant delete on table "public"."item" to "authenticated";

grant insert on table "public"."item" to "authenticated";

grant references on table "public"."item" to "authenticated";

grant select on table "public"."item" to "authenticated";

grant trigger on table "public"."item" to "authenticated";

grant truncate on table "public"."item" to "authenticated";

grant update on table "public"."item" to "authenticated";

grant delete on table "public"."item" to "service_role";

grant insert on table "public"."item" to "service_role";

grant references on table "public"."item" to "service_role";

grant select on table "public"."item" to "service_role";

grant trigger on table "public"."item" to "service_role";

grant truncate on table "public"."item" to "service_role";

grant update on table "public"."item" to "service_role";

grant delete on table "public"."item_image" to "anon";

grant insert on table "public"."item_image" to "anon";

grant references on table "public"."item_image" to "anon";

grant select on table "public"."item_image" to "anon";

grant trigger on table "public"."item_image" to "anon";

grant truncate on table "public"."item_image" to "anon";

grant update on table "public"."item_image" to "anon";

grant delete on table "public"."item_image" to "authenticated";

grant insert on table "public"."item_image" to "authenticated";

grant references on table "public"."item_image" to "authenticated";

grant select on table "public"."item_image" to "authenticated";

grant trigger on table "public"."item_image" to "authenticated";

grant truncate on table "public"."item_image" to "authenticated";

grant update on table "public"."item_image" to "authenticated";

grant delete on table "public"."item_image" to "service_role";

grant insert on table "public"."item_image" to "service_role";

grant references on table "public"."item_image" to "service_role";

grant select on table "public"."item_image" to "service_role";

grant trigger on table "public"."item_image" to "service_role";

grant truncate on table "public"."item_image" to "service_role";

grant update on table "public"."item_image" to "service_role";

grant delete on table "public"."message" to "anon";

grant insert on table "public"."message" to "anon";

grant references on table "public"."message" to "anon";

grant select on table "public"."message" to "anon";

grant trigger on table "public"."message" to "anon";

grant truncate on table "public"."message" to "anon";

grant update on table "public"."message" to "anon";

grant delete on table "public"."message" to "authenticated";

grant insert on table "public"."message" to "authenticated";

grant references on table "public"."message" to "authenticated";

grant select on table "public"."message" to "authenticated";

grant trigger on table "public"."message" to "authenticated";

grant truncate on table "public"."message" to "authenticated";

grant update on table "public"."message" to "authenticated";

grant delete on table "public"."message" to "service_role";

grant insert on table "public"."message" to "service_role";

grant references on table "public"."message" to "service_role";

grant select on table "public"."message" to "service_role";

grant trigger on table "public"."message" to "service_role";

grant truncate on table "public"."message" to "service_role";

grant update on table "public"."message" to "service_role";

grant delete on table "public"."message_image" to "anon";

grant insert on table "public"."message_image" to "anon";

grant references on table "public"."message_image" to "anon";

grant select on table "public"."message_image" to "anon";

grant trigger on table "public"."message_image" to "anon";

grant truncate on table "public"."message_image" to "anon";

grant update on table "public"."message_image" to "anon";

grant delete on table "public"."message_image" to "authenticated";

grant insert on table "public"."message_image" to "authenticated";

grant references on table "public"."message_image" to "authenticated";

grant select on table "public"."message_image" to "authenticated";

grant trigger on table "public"."message_image" to "authenticated";

grant truncate on table "public"."message_image" to "authenticated";

grant update on table "public"."message_image" to "authenticated";

grant delete on table "public"."message_image" to "service_role";

grant insert on table "public"."message_image" to "service_role";

grant references on table "public"."message_image" to "service_role";

grant select on table "public"."message_image" to "service_role";

grant trigger on table "public"."message_image" to "service_role";

grant truncate on table "public"."message_image" to "service_role";

grant update on table "public"."message_image" to "service_role";

grant delete on table "public"."thread" to "anon";

grant insert on table "public"."thread" to "anon";

grant references on table "public"."thread" to "anon";

grant select on table "public"."thread" to "anon";

grant trigger on table "public"."thread" to "anon";

grant truncate on table "public"."thread" to "anon";

grant update on table "public"."thread" to "anon";

grant delete on table "public"."thread" to "authenticated";

grant insert on table "public"."thread" to "authenticated";

grant references on table "public"."thread" to "authenticated";

grant select on table "public"."thread" to "authenticated";

grant trigger on table "public"."thread" to "authenticated";

grant truncate on table "public"."thread" to "authenticated";

grant update on table "public"."thread" to "authenticated";

grant delete on table "public"."thread" to "service_role";

grant insert on table "public"."thread" to "service_role";

grant references on table "public"."thread" to "service_role";

grant select on table "public"."thread" to "service_role";

grant trigger on table "public"."thread" to "service_role";

grant truncate on table "public"."thread" to "service_role";

grant update on table "public"."thread" to "service_role";

grant delete on table "public"."user" to "anon";

grant insert on table "public"."user" to "anon";

grant references on table "public"."user" to "anon";

grant select on table "public"."user" to "anon";

grant trigger on table "public"."user" to "anon";

grant truncate on table "public"."user" to "anon";

grant update on table "public"."user" to "anon";

grant delete on table "public"."user" to "authenticated";

grant insert on table "public"."user" to "authenticated";

grant references on table "public"."user" to "authenticated";

grant select on table "public"."user" to "authenticated";

grant trigger on table "public"."user" to "authenticated";

grant truncate on table "public"."user" to "authenticated";

grant update on table "public"."user" to "authenticated";

grant delete on table "public"."user" to "service_role";

grant insert on table "public"."user" to "service_role";

grant references on table "public"."user" to "service_role";

grant select on table "public"."user" to "service_role";

grant trigger on table "public"."user" to "service_role";

grant truncate on table "public"."user" to "service_role";

grant update on table "public"."user" to "service_role";

grant delete on table "public"."user_settings" to "anon";

grant insert on table "public"."user_settings" to "anon";

grant references on table "public"."user_settings" to "anon";

grant select on table "public"."user_settings" to "anon";

grant trigger on table "public"."user_settings" to "anon";

grant truncate on table "public"."user_settings" to "anon";

grant update on table "public"."user_settings" to "anon";

grant delete on table "public"."user_settings" to "authenticated";

grant insert on table "public"."user_settings" to "authenticated";

grant references on table "public"."user_settings" to "authenticated";

grant select on table "public"."user_settings" to "authenticated";

grant trigger on table "public"."user_settings" to "authenticated";

grant truncate on table "public"."user_settings" to "authenticated";

grant update on table "public"."user_settings" to "authenticated";

grant delete on table "public"."user_settings" to "service_role";

grant insert on table "public"."user_settings" to "service_role";

grant references on table "public"."user_settings" to "service_role";

grant select on table "public"."user_settings" to "service_role";

grant trigger on table "public"."user_settings" to "service_role";

grant truncate on table "public"."user_settings" to "service_role";

grant update on table "public"."user_settings" to "service_role";

grant delete on table "public"."watch" to "anon";

grant insert on table "public"."watch" to "anon";

grant references on table "public"."watch" to "anon";

grant select on table "public"."watch" to "anon";

grant trigger on table "public"."watch" to "anon";

grant truncate on table "public"."watch" to "anon";

grant update on table "public"."watch" to "anon";

grant delete on table "public"."watch" to "authenticated";

grant insert on table "public"."watch" to "authenticated";

grant references on table "public"."watch" to "authenticated";

grant select on table "public"."watch" to "authenticated";

grant trigger on table "public"."watch" to "authenticated";

grant truncate on table "public"."watch" to "authenticated";

grant update on table "public"."watch" to "authenticated";

grant delete on table "public"."watch" to "service_role";

grant insert on table "public"."watch" to "service_role";

grant references on table "public"."watch" to "service_role";

grant select on table "public"."watch" to "service_role";

grant trigger on table "public"."watch" to "service_role";

grant truncate on table "public"."watch" to "service_role";

grant update on table "public"."watch" to "service_role";


  create policy "Authenticated users can view categories"
  on "public"."category"
  as permissive
  for select
  to authenticated
using (true);



  create policy "Recipients can update connection status"
  on "public"."connection"
  as permissive
  for update
  to authenticated
using ((user_b = ( SELECT auth.uid() AS uid)))
with check ((user_b = ( SELECT auth.uid() AS uid)));



  create policy "Users can create connection requests"
  on "public"."connection"
  as permissive
  for insert
  to authenticated
with check (((user_a = ( SELECT auth.uid() AS uid)) AND (status = 'pending'::public.connection_status)));



  create policy "Users can delete own connections"
  on "public"."connection"
  as permissive
  for delete
  to authenticated
using (((user_a = ( SELECT auth.uid() AS uid)) OR (user_b = ( SELECT auth.uid() AS uid))));



  create policy "Users can view own connections"
  on "public"."connection"
  as permissive
  for select
  to authenticated
using (((user_a = ( SELECT auth.uid() AS uid)) OR (user_b = ( SELECT auth.uid() AS uid))));



  create policy "Anyone can view public contact info"
  on "public"."contact_info"
  as permissive
  for select
  to anon
using ((visibility = 'public'::public.visibility));



  create policy "Users can delete own contact info"
  on "public"."contact_info"
  as permissive
  for delete
  to authenticated
using ((user_id = ( SELECT auth.uid() AS uid)));



  create policy "Users can insert own contact info"
  on "public"."contact_info"
  as permissive
  for insert
  to authenticated
with check ((user_id = ( SELECT auth.uid() AS uid)));



  create policy "Users can update own contact info"
  on "public"."contact_info"
  as permissive
  for update
  to authenticated
using ((user_id = ( SELECT auth.uid() AS uid)))
with check ((user_id = ( SELECT auth.uid() AS uid)));



  create policy "Users can view contact info"
  on "public"."contact_info"
  as permissive
  for select
  to authenticated
using (((user_id = ( SELECT auth.uid() AS uid)) OR (visibility = 'public'::public.visibility) OR ((visibility = 'connections-only'::public.visibility) AND (EXISTS ( SELECT 1
   FROM public.connection
  WHERE ((connection.status = 'accepted'::public.connection_status) AND (((connection.user_a = ( SELECT auth.uid() AS uid)) AND (connection.user_b = contact_info.user_id)) OR ((connection.user_b = ( SELECT auth.uid() AS uid)) AND (connection.user_a = contact_info.user_id)))))))));



  create policy "Users can create invites"
  on "public"."invite"
  as permissive
  for insert
  to authenticated
with check ((inviter_id = ( SELECT auth.uid() AS uid)));



  create policy "Users can update invites"
  on "public"."invite"
  as permissive
  for update
  to authenticated
using (((inviter_id = ( SELECT auth.uid() AS uid)) OR ((used_by IS NULL) AND (revoked_at IS NULL))))
with check (((inviter_id = ( SELECT auth.uid() AS uid)) OR (used_by = ( SELECT auth.uid() AS uid))));



  create policy "Users can view invites"
  on "public"."invite"
  as permissive
  for select
  to authenticated
using (((inviter_id = ( SELECT auth.uid() AS uid)) OR (used_by = ( SELECT auth.uid() AS uid))));



  create policy "Users can create items"
  on "public"."item"
  as permissive
  for insert
  to authenticated
with check ((user_id = ( SELECT auth.uid() AS uid)));



  create policy "Users can delete own items"
  on "public"."item"
  as permissive
  for delete
  to authenticated
using ((user_id = ( SELECT auth.uid() AS uid)));



  create policy "Users can update own items"
  on "public"."item"
  as permissive
  for update
  to authenticated
using ((user_id = ( SELECT auth.uid() AS uid)))
with check ((user_id = ( SELECT auth.uid() AS uid)));



  create policy "Users can view items"
  on "public"."item"
  as permissive
  for select
  to authenticated
using (((user_id = ( SELECT auth.uid() AS uid)) OR ((visibility = 'public'::public.visibility) AND (status <> 'deleted'::public.item_status)) OR ((visibility = 'connections-only'::public.visibility) AND (status <> 'deleted'::public.item_status) AND (EXISTS ( SELECT 1
   FROM public.connection
  WHERE ((connection.status = 'accepted'::public.connection_status) AND (((connection.user_a = ( SELECT auth.uid() AS uid)) AND (connection.user_b = item.user_id)) OR ((connection.user_b = ( SELECT auth.uid() AS uid)) AND (connection.user_a = item.user_id)))))))));



  create policy "Users can delete own item images"
  on "public"."item_image"
  as permissive
  for delete
  to authenticated
using ((EXISTS ( SELECT 1
   FROM public.item
  WHERE ((item.id = item_image.item_id) AND (item.user_id = ( SELECT auth.uid() AS uid))))));



  create policy "Users can insert own item images"
  on "public"."item_image"
  as permissive
  for insert
  to authenticated
with check ((EXISTS ( SELECT 1
   FROM public.item
  WHERE ((item.id = item_image.item_id) AND (item.user_id = ( SELECT auth.uid() AS uid))))));



  create policy "Users can update own item images"
  on "public"."item_image"
  as permissive
  for update
  to authenticated
using ((EXISTS ( SELECT 1
   FROM public.item
  WHERE ((item.id = item_image.item_id) AND (item.user_id = ( SELECT auth.uid() AS uid))))))
with check ((EXISTS ( SELECT 1
   FROM public.item
  WHERE ((item.id = item_image.item_id) AND (item.user_id = ( SELECT auth.uid() AS uid))))));



  create policy "Users can view item images"
  on "public"."item_image"
  as permissive
  for select
  to authenticated
using ((EXISTS ( SELECT 1
   FROM public.item
  WHERE ((item.id = item_image.item_id) AND ((item.user_id = ( SELECT auth.uid() AS uid)) OR ((item.visibility = 'public'::public.visibility) AND (item.status <> 'deleted'::public.item_status)) OR ((item.visibility = 'connections-only'::public.visibility) AND (item.status <> 'deleted'::public.item_status) AND (EXISTS ( SELECT 1
           FROM public.connection
          WHERE ((connection.status = 'accepted'::public.connection_status) AND (((connection.user_a = ( SELECT auth.uid() AS uid)) AND (connection.user_b = item.user_id)) OR ((connection.user_b = ( SELECT auth.uid() AS uid)) AND (connection.user_a = item.user_id))))))))))));



  create policy "Participants can send messages"
  on "public"."message"
  as permissive
  for insert
  to authenticated
with check (((sender_id = ( SELECT auth.uid() AS uid)) AND (EXISTS ( SELECT 1
   FROM public.thread
  WHERE ((thread.id = message.thread_id) AND ((thread.creator_id = ( SELECT auth.uid() AS uid)) OR (thread.responder_id = ( SELECT auth.uid() AS uid))))))));



  create policy "Participants can view messages"
  on "public"."message"
  as permissive
  for select
  to authenticated
using ((EXISTS ( SELECT 1
   FROM public.thread
  WHERE ((thread.id = message.thread_id) AND ((thread.creator_id = ( SELECT auth.uid() AS uid)) OR (thread.responder_id = ( SELECT auth.uid() AS uid)))))));



  create policy "Recipients can update message read status"
  on "public"."message"
  as permissive
  for update
  to authenticated
using (((sender_id <> ( SELECT auth.uid() AS uid)) AND (EXISTS ( SELECT 1
   FROM public.thread
  WHERE ((thread.id = message.thread_id) AND ((thread.creator_id = ( SELECT auth.uid() AS uid)) OR (thread.responder_id = ( SELECT auth.uid() AS uid))))))))
with check (((sender_id <> ( SELECT auth.uid() AS uid)) AND (EXISTS ( SELECT 1
   FROM public.thread
  WHERE ((thread.id = message.thread_id) AND ((thread.creator_id = ( SELECT auth.uid() AS uid)) OR (thread.responder_id = ( SELECT auth.uid() AS uid))))))));



  create policy "Participants can insert message images"
  on "public"."message_image"
  as permissive
  for insert
  to authenticated
with check ((EXISTS ( SELECT 1
   FROM (public.message
     JOIN public.thread ON ((thread.id = message.thread_id)))
  WHERE ((message.id = message_image.message_id) AND (message.sender_id = ( SELECT auth.uid() AS uid)) AND ((thread.creator_id = ( SELECT auth.uid() AS uid)) OR (thread.responder_id = ( SELECT auth.uid() AS uid)))))));



  create policy "Participants can view message images"
  on "public"."message_image"
  as permissive
  for select
  to authenticated
using ((EXISTS ( SELECT 1
   FROM (public.message
     JOIN public.thread ON ((thread.id = message.thread_id)))
  WHERE ((message.id = message_image.message_id) AND ((thread.creator_id = ( SELECT auth.uid() AS uid)) OR (thread.responder_id = ( SELECT auth.uid() AS uid)))))));



  create policy "Senders can delete own message images"
  on "public"."message_image"
  as permissive
  for delete
  to authenticated
using ((EXISTS ( SELECT 1
   FROM public.message
  WHERE ((message.id = message_image.message_id) AND (message.sender_id = ( SELECT auth.uid() AS uid))))));



  create policy "Participants can delete threads"
  on "public"."thread"
  as permissive
  for delete
  to authenticated
using (((creator_id = ( SELECT auth.uid() AS uid)) OR (responder_id = ( SELECT auth.uid() AS uid))));



  create policy "Participants can view threads"
  on "public"."thread"
  as permissive
  for select
  to authenticated
using (((creator_id = ( SELECT auth.uid() AS uid)) OR (responder_id = ( SELECT auth.uid() AS uid))));



  create policy "Users can create threads"
  on "public"."thread"
  as permissive
  for insert
  to authenticated
with check ((creator_id = ( SELECT auth.uid() AS uid)));



  create policy "Public can view vendor profiles"
  on "public"."user"
  as permissive
  for select
  to anon
using ((vendor_id IS NOT NULL));



  create policy "Users can insert own profile"
  on "public"."user"
  as permissive
  for insert
  to authenticated
with check ((id = ( SELECT auth.uid() AS uid)));



  create policy "Users can update own profile"
  on "public"."user"
  as permissive
  for update
  to authenticated
using ((id = ( SELECT auth.uid() AS uid)))
with check ((id = ( SELECT auth.uid() AS uid)));



  create policy "Users can view all profiles"
  on "public"."user"
  as permissive
  for select
  to authenticated
using (true);



  create policy "Users can delete own settings"
  on "public"."user_settings"
  as permissive
  for delete
  to authenticated
using ((user_id = ( SELECT auth.uid() AS uid)));



  create policy "Users can insert own settings"
  on "public"."user_settings"
  as permissive
  for insert
  to authenticated
with check ((user_id = ( SELECT auth.uid() AS uid)));



  create policy "Users can update own settings"
  on "public"."user_settings"
  as permissive
  for update
  to authenticated
using ((user_id = ( SELECT auth.uid() AS uid)))
with check ((user_id = ( SELECT auth.uid() AS uid)));



  create policy "Users can view own settings"
  on "public"."user_settings"
  as permissive
  for select
  to authenticated
using ((user_id = ( SELECT auth.uid() AS uid)));



  create policy "Users can create watches"
  on "public"."watch"
  as permissive
  for insert
  to authenticated
with check ((user_id = ( SELECT auth.uid() AS uid)));



  create policy "Users can delete own watches"
  on "public"."watch"
  as permissive
  for delete
  to authenticated
using ((user_id = ( SELECT auth.uid() AS uid)));



  create policy "Users can update own watches"
  on "public"."watch"
  as permissive
  for update
  to authenticated
using ((user_id = ( SELECT auth.uid() AS uid)))
with check ((user_id = ( SELECT auth.uid() AS uid)));



  create policy "Users can view own watches"
  on "public"."watch"
  as permissive
  for select
  to authenticated
using ((user_id = ( SELECT auth.uid() AS uid)));
