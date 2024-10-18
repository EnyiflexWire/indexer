-- migrate:up
-------------------------------------------------------------------------------
-- View: view__events__efp_leaderboard_mutuals
-------------------------------------------------------------------------------
CREATE OR REPLACE VIEW PUBLIC.view__events__efp_leaderboard_mutuals AS
SELECT 
	public.hexlify(r.record_data) AS leader,
	count(r.record_data) AS mutuals,
	rank() OVER (ORDER BY (count(r.record_data)) DESC NULLS LAST) AS mutuals_rank
FROM public.view__join__efp_list_records_with_nft_manager_user_tags r
INNER JOIN public.view__join__efp_list_records_with_nft_manager_user_tags t
ON r."user" = public.hexlify(t.record_data) 
AND t."user" = public.hexlify(r.record_data) 
WHERE r.has_block_tag = 'false' AND r.has_mute_tag = 'false' AND t.has_block_tag = 'false' AND t.has_mute_tag = 'false' 
GROUP BY r.record_data;


-- migrate:down
-------------------------------------------------------------------------------
-- Undo View: view__events__efp_leaderboard_mutuals
-------------------------------------------------------------------------------
DROP VIEW
  IF EXISTS PUBLIC.view__events__efp_leaderboard_mutuals CASCADE;