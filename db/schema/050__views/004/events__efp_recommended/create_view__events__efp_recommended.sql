-- migrate:up
-------------------------------------------------------------------------------
-- View: view__events__efp_recommended
-------------------------------------------------------------------------------
CREATE
OR REPLACE VIEW PUBLIC.view__events__efp_recommended AS
(SELECT * FROM public.efp_recommended WHERE class = 'A' ORDER BY random() LIMIT 10)
	UNION
(SELECT * FROM public.efp_recommended WHERE class = 'B' ORDER BY random() LIMIT 5)
	UNION
(SELECT * FROM public.efp_recommended WHERE class = 'C' ORDER BY random() LIMIT 5);


-- migrate:down
-------------------------------------------------------------------------------
-- Undo View: view__events__efp_recommended
-------------------------------------------------------------------------------
DROP VIEW
  IF EXISTS PUBLIC.view__events__efp_recommended CASCADE;