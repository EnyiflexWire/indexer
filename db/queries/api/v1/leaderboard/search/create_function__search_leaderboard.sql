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
		  address,
		  name,
		  avatar,
		  mutuals_rank,
		  followers_rank,
		  following_rank,
		  blocks_rank,
		  mutuals,
		  following,
		  followers,
		  blocks,
		  updated_at
	FROM public.efp_leaderboard 
	WHERE address ~ p_term 
	OR name ~ p_term;
END;
$$;


--migrate:down