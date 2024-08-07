--migrate:up
-------------------------------------------------------------------------------
-- Function: get_user_ranks
-------------------------------------------------------------------------------
CREATE
OR REPLACE FUNCTION query.get_user_ranks (p_address types.eth_address) RETURNS TABLE (
  mutuals_rank BIGINT,
  followers_rank BIGINT,
  following_rank BIGINT,
  blocks_rank BIGINT
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
        v.blocks_rank 
    FROM public.efp_leaderboard v
    WHERE v.address = normalized_addr;
END;
$$;




--migrate:down