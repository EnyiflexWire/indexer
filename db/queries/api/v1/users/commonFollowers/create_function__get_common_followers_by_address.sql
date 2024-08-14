--migrate:up
-------------------------------------------------------------------------------
-- Function: get_common_followers_by_address
-------------------------------------------------------------------------------
CREATE
OR REPLACE FUNCTION query.get_common_followers_by_address(p_user_address types.eth_address, p_target_address types.eth_address) RETURNS TABLE (
    address types.eth_address,
    name TEXT,
    avatar TEXT,
    mutuals_rank BIGINT
) LANGUAGE plpgsql AS $$
DECLARE
    normalized_u_addr types.eth_address;
    normalized_t_addr types.eth_address;
BEGIN
	-- Normalize the input address to lowercase
    normalized_u_addr := public.normalize_eth_address(p_user_address);
    normalized_t_addr := public.normalize_eth_address(p_target_address);

RETURN QUERY

SELECT 
    public.hexlify(r.record_data)::types.eth_address as address,
    l.name,
    l.avatar,
    l.mutuals_rank as mutuals_rank
FROM public.view__join__efp_list_records_with_nft_manager_user_tags r
INNER JOIN public.efp_leaderboard l ON l.address = public.hexlify(r.record_data)
    AND r.user = normalized_u_addr -- user 1
    AND r.has_block_tag = FALSE
    AND r.has_block_tag = FALSE
    AND EXISTS(
        SELECT 1
        FROM public.view__join__efp_list_records_with_nft_manager_user_tags r2 
        WHERE r2.user = public.hexlify(r.record_data) 
        AND public.hexlify(r2.record_data) = normalized_t_addr -- user 2 
        AND r2.has_block_tag = FALSE
        AND r2.has_block_tag = FALSE
    );

END;
$$;


--migrate:down