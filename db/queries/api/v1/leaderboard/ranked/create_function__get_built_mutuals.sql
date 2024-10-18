--migrate:up
-------------------------------------------------------------------------------
-- Function: get_built_mutuals
-------------------------------------------------------------------------------
CREATE
OR REPLACE FUNCTION query.get_built_mutuals () RETURNS TABLE (
    leader types.eth_address,
    mutuals BIGINT,
    mutuals_rank BIGINT
) LANGUAGE plpgsql AS $$
BEGIN

-- build a table of all list records with tags 
    CREATE TEMPORARY TABLE temp_all_records (
        nft_chain_id bigint,
        nft_contract_address varchar(42),
        token_id bigint,
        owner varchar(42),
        manager varchar(42),
        "user" varchar(42),
        record_data bytea,
        record_version smallint,
        record_type smallint,
        tags types.efp_tag[]       
    ) ON COMMIT DROP;

    INSERT INTO temp_all_records SELECT r.chain_id,
        r.contract_address,
        l.token_id,
        l.owner,
        l.manager,
        l."user",
        r.record_data,
        r.record_version,
        r.record_type,
        array_agg(t.tag) FILTER (WHERE t.tag IS NOT NULL) AS tags
    FROM efp_list_records r
    LEFT JOIN efp_list_record_tags t ON r.chain_id::bigint = t.chain_id::bigint AND r.contract_address::text = t.contract_address::text AND r.slot::bytea = t.slot::bytea AND r.record = t.record
    JOIN view__join__efp_lists_with_metadata l ON l.list_storage_location_chain_id = r.chain_id::bigint AND l.list_storage_location_contract_address::text = r.contract_address::text AND l.list_storage_location_slot::bytea = r.slot::bytea
    JOIN efp_account_metadata meta ON l."user"::text = meta.address::text AND l.token_id::bigint = convert_hex_to_bigint(meta.value::text)
    GROUP BY 
        r.chain_id, 
        r.contract_address, 
        l.token_id,
        l.owner,
        l.manager,
        l."user",
        r.record_version, 
        r.record_type, 
        r.record_data;

    RETURN QUERY
    SELECT 
        hexlify(r.record_data)::types.eth_address AS leader,
        count(r.record_data) AS mutuals,
        rank() OVER (ORDER BY (count(r.record_data)) DESC NULLS LAST) AS mutuals_rank
    FROM temp_all_records r
    JOIN temp_all_records s ON s."user" = hexlify(r.record_data) AND r."user" = hexlify(s.record_data)
    GROUP BY r.record_data;
END;
$$;




--migrate:down