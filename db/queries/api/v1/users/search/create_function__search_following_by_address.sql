--migrate:up
-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
CREATE
OR REPLACE FUNCTION query.search_following_by_address (p_address types.eth_address, p_term TEXT, p_limit BIGINT, p_offset BIGINT) RETURNS TABLE (
  name TEXT,
  avatar TEXT,
  efp_list_nft_token_id BIGINT,
  record_version types.uint8,
  record_type types.uint8,
  following_address types.eth_address,
  tags types.efp_tag [],
  updated_at TIMESTAMP WITH TIME ZONE
) LANGUAGE plpgsql AS $$
DECLARE
    normalized_addr types.eth_address;
BEGIN
    normalized_addr := public.normalize_eth_address(p_address);

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
    FROM query.get_following__record_type_001(normalized_addr) v
    JOIN public.ens_metadata meta ON meta.address = v.following_address
    AND (meta.name ~ p_term OR v.following_address ~ p_term)
    LIMIT p_limit
    OFFSET p_offset;
END;
$$;




--migrate:down