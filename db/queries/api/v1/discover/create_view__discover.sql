-- migrate:up
-------------------------------------------------------------------------------
-- View: view__discover
-------------------------------------------------------------------------------
CREATE
OR REPLACE VIEW PUBLIC.view__discover AS
SELECT 
    DISTINCT r.address,
    l.name,
    l.avatar,
    l.followers,
    l.following 
FROM public.view__latest_follows r
LEFT JOIN efp_leaderboard l ON l.address = r.address;




-- migrate:down
-------------------------------------------------------------------------------
-- Undo View: view__discover
-------------------------------------------------------------------------------
DROP VIEW
  IF EXISTS PUBLIC.view__discover CASCADE;