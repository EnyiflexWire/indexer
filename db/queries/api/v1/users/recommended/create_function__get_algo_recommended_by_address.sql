--migrate:up
-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
CREATE
OR REPLACE FUNCTION query.get_algo_recommended_by_address (p_address types.eth_address, p_limit BIGINT, p_offset BIGINT) RETURNS TABLE (
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
DECLARE
    normalized_addr types.eth_address;
BEGIN

    normalized_addr := public.normalize_eth_address(p_address);

    CREATE TEMPORARY TABLE temp_follow_records (
        nft_chain_id bigint,
        nft_contract_address varchar(42),
        token_id bigint,
        owner varchar(42),
        manager varchar(42),
        "user" varchar(42),
        list_storage_location_chain_id bigint,
        list_storage_location_contract_address varchar(42),
        list_storage_location_slot bytea,
        record bytea,
        record_version smallint,
        record_type smallint,
        record_data bytea,
        tags types.efp_tag[],
        updated_at timestamp with TIME ZONE,
        has_block_tag boolean,
        has_mute_tag boolean
    ) ON COMMIT DROP;

    INSERT INTO temp_follow_records SELECT l.nft_chain_id,
        l.nft_contract_address,
        l.token_id,
        l.owner,
        l.manager,
        l."user",
        l.list_storage_location_chain_id,
        l.list_storage_location_contract_address,
        l.list_storage_location_slot,
        record_tags.record,
        record_tags.record_version,
        record_tags.record_type,
        record_tags.record_data,
        record_tags.tags,
        record_tags.updated_at,
        CASE
            WHEN 'block'::text = ANY (record_tags.tags::text[]) THEN true
            ELSE false
        END AS has_block_tag,
        CASE
            WHEN 'mute'::text = ANY (record_tags.tags::text[]) THEN true
            ELSE false
        END AS has_mute_tag
    FROM view__join__efp_list_records_with_tags record_tags
        JOIN view__join__efp_lists_with_metadata l ON l.list_storage_location_chain_id = record_tags.chain_id::bigint AND l.list_storage_location_contract_address::text = record_tags.contract_address::text AND l.list_storage_location_slot::bytea = record_tags.slot::bytea
        JOIN efp_account_metadata meta ON l."user"::text = meta.address::text AND l.token_id::bigint = convert_hex_to_bigint(meta.value::text)
        WHERE 
        l."user" = normalized_addr AND
        record_tags.record_version = 1 AND
        record_tags.record_type = 1;

    RETURN QUERY
    SELECT  
        m.address AS address,
        m.name AS "name",        
        m.avatar AS avatar,
        m.records::text,
        b.followers,
        b.following,
        b.mutuals_rank,
        b.followers_rank,
        b.following_rank,
        b.top8_rank,
        b.blocks_rank
    FROM public.efp_leaderboard b
    LEFT JOIN public.ens_metadata m ON m.address = b.address 
    LEFT JOIN public.view__trending trending ON trending.address = b.address
    WHERE  
        b.address <> normalized_addr AND
        b.following > 0 AND
        b.name IS NOT NULL AND
        b.avatar IS NOT NULL AND
        NOT EXISTS (
            SELECT 1 
            FROM temp_follow_records l 
            WHERE l."user" = normalized_addr AND b.address = PUBLIC.hexlify(l.record_data)::types.eth_address  
        )
    GROUP BY 
        m.address,
        m.name,        
        m.avatar,
        m.records::text,
        b.followers,
        b.following,
        b.mutuals_rank,
        b.followers_rank,
        b.following_rank,
        b.top8_rank,
        b.blocks_rank, 
        trending.count
    ORDER BY trending.count DESC NULLS LAST
    LIMIT p_limit
    OFFSET p_offset;
END;
$$;



--migrate:down