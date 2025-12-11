-- Increase statement timeout for authenticated role to support pg_sleep(5) in RPC functions
-- Default is 8s, we need at least 10s for safety (5s sleep + query execution time)
alter role authenticated set statement_timeout = '15s';

-- Also increase for anon role which may be used in some scenarios
alter role anon set statement_timeout = '15s';
