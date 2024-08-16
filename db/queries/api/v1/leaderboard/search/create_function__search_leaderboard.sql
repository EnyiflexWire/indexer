--migrate:up
-------------------------------------------------------------------------------
-- Function: search_leaderboard
-- Description: allows users to search for specific leaderboard records
-- Parameters:
--   - p_term (TEXT): The search term.
-- Returns: A set of records from the efp_leaderboard table
-------------------------------------------------------------------------------

CREATE
OR REPLACE FUNCTION query.search_leaderboard (p_term TEXT) RETURNS TABLE (
  address types.eth_address,
  name TEXT,
  avatar TEXT,
  mutuals_rank BIGINT,
  followers_rank BIGINT,
  following_rank BIGINT,
  blocks_rank BIGINT,
  mutuals BIGINT,
  following BIGINT,
  followers BIGINT,
  blocks BIGINT,
  updated_at TIMESTAMP WITH TIME ZONE
) LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    
    SELECT 
        lb.address,
        lb.name,
        lb.avatar,
        lb.mutuals_rank,
        lb.followers_rank,
        lb.following_rank,
        lb.blocks_rank,
        lb.mutuals,
        lb.following,
        lb.followers,
        lb.blocks,
        lb.updated_at
    FROM public.efp_leaderboard lb 
    WHERE lb.address ~ p_term 
    OR lb.name ~ p_term;
END;
$$;


--migrate:down