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
	primary_list_id VARCHAR;
BEGIN
	primary_list_id = to_hex(p_list_id);

    SELECT v.address
	INTO primary_list_address
	FROM public.efp_account_metadata AS v
	WHERE v.value = '0x' || LPAD(primary_list_id, 64, '0')
	AND v.key = 'primary-list';

    RETURN primary_list_address;
END;
$$ LANGUAGE plpgsql;



--migrate:down