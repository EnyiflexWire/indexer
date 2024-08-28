--migrate:up
-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
CREATE
OR REPLACE FUNCTION query.search_following_by_list (p_list_id INT, p_term TEXT, p_limit BIGINT, p_offset BIGINT) RETURNS TABLE (
  name TEXT,
  avatar TEXT,
  efp_list_nft_token_id BIGINT,
  record_version types.uint8,
  record_type types.uint8,
  following_address types.eth_address,
  tags types.efp_tag [],
  updated_at TIMESTAMP WITH TIME ZONE
) LANGUAGE plpgsql AS $$
BEGIN

IF public.is_valid_address(p_term) IS TRUE THEN
    RETURN QUERY
    SELECT  
        meta.name,
        meta.avatar,
        v.efp_list_nft_token_id,
        v.record_version,
        v.record_type,
        v.following_address,
        v.tags,
        v.updated_at
    FROM query.get_following_by_list(p_list_id) v
    LEFT JOIN public.ens_metadata meta ON meta.address = v.following_address
    WHERE v.following_address ~ p_term
    LIMIT p_limit
    OFFSET p_offset;
ELSE
    RETURN QUERY
    SELECT  
        meta.name,
        meta.avatar,
        v.efp_list_nft_token_id,
        v.record_version,
        v.record_type,
        v.following_address,
        v.tags,
        v.updated_at
    FROM query.get_following_by_list(p_list_id) v
    JOIN public.ens_metadata meta ON meta.address = v.following_address
    AND (meta.name ~ p_term OR v.following_address ~ p_term)
    LIMIT p_limit
    OFFSET p_offset;
END IF;
END;
$$;




--migrate:down