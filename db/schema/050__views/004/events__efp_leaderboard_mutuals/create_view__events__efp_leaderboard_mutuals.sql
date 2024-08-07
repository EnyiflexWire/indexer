-- migrate:up
-------------------------------------------------------------------------------
-- View: view__events__efp_leaderboard_mutuals
-------------------------------------------------------------------------------
CREATE
OR REPLACE VIEW PUBLIC.view__events__efp_leaderboard_mutuals AS
SELECT public.hexlify(r.record_data) as leader, COUNT(r.record_data) as mutuals 
FROM public.view__join__efp_list_records_with_nft_manager_user_tags r
WHERE public.hexlify(r.record_data) <> r.user
AND EXISTS (
    SELECT 1 
    FROM public.view__join__efp_list_records_with_nft_manager_user_tags r2
    WHERE public.hexlify(r2.record_data) = r.user
    AND public.hexlify(r.record_data) = r2.user
)
GROUP BY leader;


-- migrate:down
-------------------------------------------------------------------------------
-- Undo View: view__events__efp_leaderboard_mutuals
-------------------------------------------------------------------------------
DROP VIEW
  IF EXISTS PUBLIC.view__events__efp_leaderboard_mutuals CASCADE;