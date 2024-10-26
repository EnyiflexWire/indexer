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
    addr_u_bytea bytea;
    addr_t_bytea bytea;
    u_primary_list_token_id BIGINT;
    t_primary_list_token_id BIGINT;
    u_list_storage_location_chain_id BIGINT;
    u_list_storage_location_contract_address VARCHAR(42);
    u_list_storage_location_storage_slot types.efp_list_storage_location_slot;
    t_list_storage_location_chain_id BIGINT;
    t_list_storage_location_contract_address VARCHAR(42);
    t_list_storage_location_storage_slot types.efp_list_storage_location_slot;
BEGIN
	-- Normalize the input address to lowercase
    normalized_u_addr := public.normalize_eth_address(p_user_address);
    addr_u_bytea := public.unhexlify(normalized_u_addr);

    SELECT v.primary_list_token_id
    INTO u_primary_list_token_id
    FROM public.view__events__efp_accounts_with_primary_list AS v
    WHERE v.address = normalized_u_addr;

    IF u_primary_list_token_id IS NOT NULL THEN

      -- Now determine the list storage location for the primary list token id
      SELECT
        v.efp_list_storage_location_chain_id,
        v.efp_list_storage_location_contract_address,
        v.efp_list_storage_location_slot
      INTO
        u_list_storage_location_chain_id,
        u_list_storage_location_contract_address,
        u_list_storage_location_storage_slot
      FROM
        public.view__events__efp_list_storage_locations AS v
      WHERE
        v.efp_list_nft_token_id = u_primary_list_token_id;
    END IF;

    normalized_t_addr := public.normalize_eth_address(p_target_address);
    addr_t_bytea := public.unhexlify(normalized_t_addr);

    SELECT v.primary_list_token_id
    INTO t_primary_list_token_id
    FROM public.view__events__efp_accounts_with_primary_list AS v
    WHERE v.address = normalized_t_addr;

    IF t_primary_list_token_id IS NOT NULL THEN
      -- Now determine the list storage location for the primary list token id
      SELECT
        v.efp_list_storage_location_chain_id,
        v.efp_list_storage_location_contract_address,
        v.efp_list_storage_location_slot
      INTO
        t_list_storage_location_chain_id,
        t_list_storage_location_contract_address,
        t_list_storage_location_storage_slot
      FROM
        public.view__events__efp_list_storage_locations AS v
      WHERE
        v.efp_list_nft_token_id = t_primary_list_token_id;
    END IF;

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