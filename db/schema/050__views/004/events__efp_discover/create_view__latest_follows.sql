-- migrate:up
-------------------------------------------------------------------------------
-- View: view__latest_follows
-------------------------------------------------------------------------------
CREATE
OR REPLACE VIEW PUBLIC.view__latest_follows AS
SELECT 
    public.hexlify(record_data) as address,
	updated_at,
    ROW_NUMBER () OVER (
    ORDER BY 
      updated_at DESC
    ) as _index
FROM  public.view__join__efp_list_records_with_nft_manager_user_tags 
--WHERE updated_at > now()::date - interval '12h'
ORDER BY updated_at DESC
LIMIT 500;




-- migrate:down
-------------------------------------------------------------------------------
-- Undo View: view__latest_follows
-------------------------------------------------------------------------------
DROP VIEW
  IF EXISTS PUBLIC.view__latest_follows CASCADE;