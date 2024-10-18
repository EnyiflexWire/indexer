-- migrate:up
-------------------------------------------------------------------------------
-- View: view__trending
-------------------------------------------------------------------------------
CREATE OR REPLACE VIEW PUBLIC.view__trending AS
SELECT 
    public.hexlify(record_tags.record_data) as address,
    ens.name,
    ens.avatar,
    count(record_tags.record_data)
FROM public.view__join__efp_list_records_with_tags record_tags
LEFT JOIN public.ens_metadata ens ON public.hexlify(record_tags.record_data) = ens.address
WHERE NOW() - record_tags.updated_at::timestamptz <= interval '6 hours'
GROUP BY 1,2,3
ORDER BY 4 DESC;





-- migrate:down
-------------------------------------------------------------------------------
-- Undo View: view__trending
-------------------------------------------------------------------------------
DROP VIEW
  IF EXISTS PUBLIC.view__trending CASCADE;