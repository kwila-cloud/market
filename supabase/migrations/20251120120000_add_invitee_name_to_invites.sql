-- Add invitee_name column to invite table
alter table invite add column invitee_name text not null default '';
