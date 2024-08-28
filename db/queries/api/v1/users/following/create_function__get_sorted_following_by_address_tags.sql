--migrate:up
-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
CREATE
OR REPLACE FUNCTION query.get_sorted_following_by_address_tags (p_address types.eth_address, p_tags types.efp_tag[], p_sort text) RETURNS TABLE (
  efp_list_nft_token_id BIGINT,
  record_version types.uint8,
  record_type types.uint8,
  following_address types.eth_address,
  tags types.efp_tag [],
  updated_at TIMESTAMP WITH TIME ZONE
) LANGUAGE plpgsql AS $$
DECLARE
    direction text;
    normalized_addr types.eth_address;
BEGIN
    direction = LOWER(p_sort);
    normalized_addr := public.normalize_eth_address(p_address);

    IF cardinality(p_tags) > 0 THEN
        RETURN QUERY
        SELECT 
            v.efp_list_nft_token_id,
            v.record_version,
            v.record_type,
            v.following_address,
            v.tags,
            v.updated_at 
        FROM query.get_following__record_type_001(normalized_addr) v
        LEFT JOIN public.efp_leaderboard l 
        ON v.following_address = l.address
        AND v.tags && p_tags
        ORDER BY  
            (CASE WHEN direction = 'followers' THEN l.followers END) DESC,
            (CASE WHEN direction = 'earliest' THEN v.updated_at END) ASC,
            (CASE WHEN direction = 'latest' THEN v.updated_at END) DESC;
    ELSE
        RETURN QUERY
        SELECT 
            v.efp_list_nft_token_id,
            v.record_version,
            v.record_type,
            v.following_address,
            v.tags,
            v.updated_at
        FROM query.get_following__record_type_001(normalized_addr) v
        LEFT JOIN public.efp_leaderboard l 
        ON v.following_address = l.address
        ORDER BY  
            (CASE WHEN direction = 'followers' THEN l.followers END) DESC,
            (CASE WHEN direction = 'earliest' THEN v.updated_at END) ASC,
            (CASE WHEN direction = 'latest' THEN v.updated_at END) DESC;
    END IF;
END;
$$;




--migrate:down