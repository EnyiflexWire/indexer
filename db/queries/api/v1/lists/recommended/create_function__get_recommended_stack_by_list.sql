--migrate:up
-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
CREATE
OR REPLACE FUNCTION query.get_recommended_stack_by_list (p_list_id INT, p_limit BIGINT, p_offset BIGINT) RETURNS TABLE (
  address types.eth_address,
  name TEXT,
  avatar TEXT,
  records TEXT,
  followers BIGINT,
  following BIGINT,
  mutuals_rank BIGINT,
  followers_rank BIGINT,
  following_rank BIGINT,
  top8_rank BIGINT,
  blocks_rank BIGINT
) LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY

	SELECT 
		r.address,
		m.name,
		m.avatar,
		m.records::text,
		l.followers,
		l.following,
		l.mutuals_rank,
		l.followers_rank,
		l.following_rank,
		l.top8_rank,
		l.blocks_rank
	FROM public.efp_recommended r
	LEFT JOIN public.efp_leaderboard l ON l.address = r.address
	LEFT JOIN public.ens_metadata m ON m.address = r.address
	WHERE NOT EXISTS (
		SELECT 1 
		FROM query.get_all_following_by_list(p_list_id) fol
		WHERE r.address = fol.following_address
	)
	ORDER BY r.index ASC
    LIMIT p_limit   
    OFFSET p_offset;
END;
$$;




--migrate:down