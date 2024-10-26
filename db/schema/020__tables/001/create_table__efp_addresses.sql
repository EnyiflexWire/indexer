-- migrate:up
-------------------------------------------------------------------------------
-- Table: efp_addresses
-------------------------------------------------------------------------------
CREATE TABLE
  public.efp_addresses (
    "address" types.eth_address NOT NULL PRIMARY KEY
  );


-- migrate:down
-------------------------------------------------------------------------------
-- Undo Table: efp_addresses
-------------------------------------------------------------------------------
DROP TABLE
  IF EXISTS public.efp_addresses CASCADE;