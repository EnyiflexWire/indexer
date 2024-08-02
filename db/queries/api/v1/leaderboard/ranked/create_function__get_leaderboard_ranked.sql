--migrate:up
-------------------------------------------------------------------------------
-- Function: get_get_leaderboard_ranked
-------------------------------------------------------------------------------
CREATE
OR REPLACE FUNCTION query.get_leaderboard_ranked (p_limit INT, p_offset INT, p_column text, p_sort text) RETURNS TABLE (
  address types.eth_address,
  name text,
  avatar text,
  mutuals_rank BIGINT,
  mutuals BIGINT,
  following BIGINT,
  followers BIGINT,
  blocks BIGINT,
  created_at TIMESTAMP WITH TIME ZONE,
  updated_at TIMESTAMP WITH TIME ZONE
) LANGUAGE plpgsql AS $$
DECLARE
	direction text;
    col text;
BEGIN
    direction = LOWER(p_sort);
    col = LOWER(p_column);

    IF col = 'following' THEN
        RETURN QUERY
        SELECT * 
        FROM public.efp_leaderboard v
        ORDER BY  
            (CASE WHEN direction = 'asc' THEN v.following END) asc,
            (CASE WHEN direction = 'desc' THEN v.following END) desc
        LIMIT p_limit
        OFFSET p_offset;
    ELSEIF col = 'followers' THEN
        RETURN QUERY
        SELECT * 
        FROM public.efp_leaderboard v
        ORDER BY  
            (CASE WHEN direction = 'asc' THEN v.followers END) asc,
            (CASE WHEN direction = 'desc' THEN v.followers END) desc
        LIMIT p_limit
        OFFSET p_offset;
    ELSEIF col = 'blocks' THEN
        RETURN QUERY
        SELECT * 
        FROM public.efp_leaderboard v
        ORDER BY  
            (CASE WHEN direction = 'asc' THEN v.blocks END) asc,
            (CASE WHEN direction = 'desc' THEN v.blocks END) desc
        LIMIT p_limit
        OFFSET p_offset;
    ELSE
        RETURN QUERY
        SELECT * 
        FROM public.efp_leaderboard v
        ORDER BY  
            (CASE WHEN direction = 'asc' THEN v.mutuals END) asc,
            (CASE WHEN direction = 'desc' THEN v.mutuals END) desc
        LIMIT p_limit
        OFFSET p_offset;
    END IF;
END;
$$;




--migrate:down