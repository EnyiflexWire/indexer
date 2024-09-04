
-- migrate:up

-- View: view__join__efp_lists_with_metadata
-------------------------------------------------------------------------------
CREATE
OR REPLACE VIEW PUBLIC.view__join__efp_lists_with_metadata AS
SELECT 
    nft_chain_id,
    nft_contract_address,
    token_id,
    owner,
    (SELECT m.value::types.eth_address 
                FROM public.efp_list_metadata m
                WHERE m.chain_id = l.list_storage_location_chain_id
                AND m.contract_address = l.list_storage_location_contract_address
                AND m.slot = l.list_storage_location_slot
                AND m.key = 'manager'
            ) AS manager,
    (SELECT m.value::types.eth_address 
                FROM public.efp_list_metadata m
                WHERE m.chain_id = l.list_storage_location_chain_id
                AND m.contract_address = l.list_storage_location_contract_address
                AND m.slot = l.list_storage_location_slot
                AND m.key = 'user'
            ) AS user,
    list_storage_location,
    list_storage_location_chain_id,
    list_storage_location_contract_address,
    list_storage_location_slot,
    l.created_at,
    l.updated_at
FROM public.efp_lists l;

-- migrate:down
-------------------------------------------------------------------------------
-- Undo View: view__join__efp_lists_with_metadata
-------------------------------------------------------------------------------
DROP VIEW
IF EXISTS PUBLIC.view__join__efp_lists_with_metadata CASCADE;