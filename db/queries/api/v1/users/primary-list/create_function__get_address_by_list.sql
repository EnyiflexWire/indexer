--migrate:up
-------------------------------------------------------------------------------
-- Function: get_address_by_list
-- Description: Retrieves the address for a given primary list from the
--              account_metadata table.
-- Parameters:
--   - p_list_id (INT): The primary list id for which to retrieve the address.
-- Returns: The eth address for the given primary list id.
--          Returns NULL if no address is found.
-------------------------------------------------------------------------------
CREATE
OR REPLACE FUNCTION query.get_address_by_list (p_list_id INT) RETURNS VARCHAR(42) AS $$
DECLARE
    primary_list_address VARCHAR(42);
BEGIN

    SELECT v.user 
    INTO primary_list_address
    FROM public.view__join__efp_lists_with_metadata as v
    WHERE v.token_id = p_list_id;

    RETURN primary_list_address;
END;
$$ LANGUAGE plpgsql;



--migrate:down