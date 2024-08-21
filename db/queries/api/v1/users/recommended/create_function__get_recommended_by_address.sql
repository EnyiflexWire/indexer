--migrate:up
-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
CREATE
OR REPLACE FUNCTION query.get_recommended_by_address (p_address types.eth_address) RETURNS TABLE (
  name TEXT,
  address types.eth_address,
  avatar TEXT,
  class TEXT,
  created_at TIMESTAMP WITH TIME ZONE
) LANGUAGE plpgsql AS $$
DECLARE
    normalized_addr types.eth_address;
BEGIN
    normalized_addr := public.normalize_eth_address(p_address);
    RETURN QUERY
    ( SELECT efp_recommended.name,
        efp_recommended.address,
        efp_recommended.avatar,
        efp_recommended.class,
        efp_recommended.created_at
    FROM public.efp_recommended
    WHERE efp_recommended.class = 'A'::text
        AND NOT EXISTS (
            SELECT 1 
            FROM query.get_following_by_list(normalized_addr) fol
            WHERE efp_recommended.address = fol.following_address
        )
    ORDER BY (random())
    LIMIT 10)
    UNION
    ( SELECT efp_recommended.name,
        efp_recommended.address,
        efp_recommended.avatar,
        efp_recommended.class,
        efp_recommended.created_at
    FROM public.efp_recommended
    WHERE efp_recommended.class = 'B'::text
        AND NOT EXISTS (
            SELECT 1 
            FROM query.get_following_by_list(normalized_addr) fol
            WHERE efp_recommended.address = fol.following_address
        )
    ORDER BY (random())
    LIMIT 5)
    UNION
    ( SELECT efp_recommended.name,
        efp_recommended.address,
        efp_recommended.avatar,
        efp_recommended.class,
        efp_recommended.created_at
    FROM public.efp_recommended
    WHERE efp_recommended.class = 'C'::text
        AND NOT EXISTS (
            SELECT 1 
            FROM query.get_following_by_list(5) fol
            WHERE efp_recommended.address = fol.following_address
        )
    ORDER BY (random())
    LIMIT 5);
END;
$$;




--migrate:down