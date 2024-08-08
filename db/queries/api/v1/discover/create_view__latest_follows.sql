-- migrate:up
-------------------------------------------------------------------------------
-- View: view__latest_follows
-------------------------------------------------------------------------------
CREATE
OR REPLACE VIEW PUBLIC.view__latest_follows AS
SELECT public.hexlify(record_data) as address 
FROM  public.view__join__efp_list_records_with_nft_manager_user_tags 
ORDER BY updated_at DESC
LIMIT 15;




-- migrate:down
-------------------------------------------------------------------------------
-- Undo View: view__latest_follows
-------------------------------------------------------------------------------
DROP VIEW
  IF EXISTS PUBLIC.view__latest_follows CASCADE;