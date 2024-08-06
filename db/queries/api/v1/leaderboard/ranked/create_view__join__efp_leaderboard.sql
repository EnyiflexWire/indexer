-- migrate:up
-------------------------------------------------------------------------------
-- View: view__join__efp_leaderboard
-------------------------------------------------------------------------------
CREATE
OR REPLACE VIEW PUBLIC.view__join__efp_leaderboard AS
SELECT
    fers.address,
    COALESCE(ens.name) AS ens_name,
    COALESCE(ens.avatar) AS ens_avatar,
    RANK () OVER (
        ORDER BY mut.mutuals DESC NULLS LAST
    ) as mutuals_rank,
    RANK () OVER (
        ORDER BY fers.followers_count DESC NULLS LAST
    ) as followers_rank,
    RANK () OVER (
        ORDER BY fing.following_count DESC NULLS LAST
    ) as following_rank,
    RANK () OVER (
        ORDER BY blocks.blocks_count DESC NULLS LAST
    ) as blocks_rank,
    COALESCE(mut.mutuals, 0 ) as mutuals,
    COALESCE(fers.followers_count, 0 ) as followers,
    COALESCE(fing.following_count, 0 ) as following,
    COALESCE(blocks.blocks_count, 0 ) as blocks
FROM query.get_leaderboard_followers(10000) fers 
LEFT OUTER JOIN query.get_leaderboard_following(10000) fing ON fing.address = fers.address 
LEFT OUTER JOIN query.get_leaderboard_blocks(10000) blocks ON blocks.address = fers.address
LEFT OUTER JOIN public.view__events__efp_leaderboard_mutuals mut ON mut.leader = fers.address
LEFT OUTER JOIN ens_metadata ens ON ens.address::text = fers.address::text
ORDER BY mut.mutuals DESC NULLS LAST;

-- migrate:down
-------------------------------------------------------------------------------
-- Undo View: view__join__efp_leaderboard
-------------------------------------------------------------------------------
DROP VIEW
  IF EXISTS PUBLIC.view__join__efp_leaderboard CASCADE;