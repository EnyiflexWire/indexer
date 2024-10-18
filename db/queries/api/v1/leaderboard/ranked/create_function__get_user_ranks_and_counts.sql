--migrate:up
-------------------------------------------------------------------------------
-- Function: get_user_ranks_and_counts
-------------------------------------------------------------------------------
CREATE
OR REPLACE FUNCTION query.get_user_ranks_and_counts (p_address types.eth_address) RETURNS TABLE (
  mutuals_rank BIGINT,
  followers_rank BIGINT,
  following_rank BIGINT,
  top8_rank BIGINT,
  blocks_rank BIGINT,
  mutuals BIGINT,
  following BIGINT,
  followers BIGINT,
  top8 BIGINT,
  blocks BIGINT
) LANGUAGE plpgsql AS $$
DECLARE 
    normalized_addr types.eth_address;
BEGIN
    normalized_addr := public.normalize_eth_address(p_address);
    RETURN QUERY
    
    SELECT
        v.mutuals_rank,
        v.followers_rank,
        v.following_rank,
        v.top8_rank,
        v.blocks_rank,
        v.mutuals,
        v.following,
        v.followers,
        v.top8,
        v.blocks 
    FROM public.efp_leaderboard v
    WHERE v.address = normalized_addr;
END;
$$;




--migrate:down