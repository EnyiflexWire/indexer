-- migrate:up
-------------------------------------------------------------------------------
-- Table: efp_mutuals
-------------------------------------------------------------------------------
CREATE TABLE
  public.efp_mutuals (
    "address" types.eth_address NOT NULL PRIMARY KEY,
    "mutuals_rank" BIGINT,
    "mutuals" BIGINT DEFAULT 0
  );

-- migrate:down
-------------------------------------------------------------------------------
-- Undo Table: efp_mutuals
-------------------------------------------------------------------------------
DROP TABLE
  IF EXISTS public.efp_mutuals CASCADE;