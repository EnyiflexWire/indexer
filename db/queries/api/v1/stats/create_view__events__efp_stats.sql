-- migrate:up
-------------------------------------------------------------------------------
-- View: view__efp_stats
-------------------------------------------------------------------------------
CREATE
OR REPLACE VIEW PUBLIC.view__efp_stats AS
SELECT 
    COUNT(DISTINCT (public.hexlify(record_data))) as address_count, 
    MAX (token_id) as list_count, 
    (
        SELECT COUNT(*) 
        FROM public.events 
        WHERE event_name = 'ListOp'	
    ) as list_op_count,
    (
        SELECT COUNT(DISTINCT event_args->>'to') FROM public.events 
        WHERE event_name = 'Transfer'	
        AND event_args @> '{"from": "0x0000000000000000000000000000000000000000"}'
    ) AS user_count 
FROM 
    public.view__join__efp_list_records_with_nft_manager_user_tags_no_prim;




-- migrate:down
-------------------------------------------------------------------------------
-- Undo View: view__efp_stats
-------------------------------------------------------------------------------
DROP VIEW
  IF EXISTS PUBLIC.view__efp_stats CASCADE;