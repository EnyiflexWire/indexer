--migrate:up
-------------------------------------------------------------------------------
-- Function: get_sorted_following_by_list_tags
-- Description: Retrieves a limited list of primary lists followed by a user from 
--              the view_list_records_with_nft_manager_user_tags. Filters tokens
--              by version and type, excluding blocked or muted relationships.
--              Leverages primary list token ID from get_primary_list. If no 
--              primary list is found, returns an empty result set.
-- Parameters:
--   - p_list_id  (INT): Identifier of the user to find the following addresses.
--   - p_tags (efp_tag): Number of records to retrieve
--   - p_sort    (TEXT): Starting index to begin returned record set
-- Returns: A table with 'efp_list_nft_token_id' (BIGINT), 'record_version'
--          (types.uint8), 'record_type' (types.uint8), and 'following_address'
--          (types.eth_address), representing the list token ID, record
--          version, record type, and following address.
-------------------------------------------------------------------------------
CREATE
OR REPLACE FUNCTION query.get_sorted_following_by_list_tags (p_list_id INT, p_tags types.efp_tag[], p_sort text) RETURNS TABLE (
  efp_list_nft_token_id BIGINT,
  record_version types.uint8,
  record_type types.uint8,
  following_address types.eth_address,
  tags types.efp_tag [],
  r_updated_at TIMESTAMP WITH TIME ZONE
) LANGUAGE plpgsql AS $$
DECLARE
    direction text;
BEGIN
    direction = LOWER(p_sort);

    IF cardinality(p_tags) > 0 THEN
        RETURN QUERY
        SELECT 
            v.efp_list_nft_token_id,
            v.record_version,
            v.record_type,
            v.following_address,
            v.tags,
            v.updated_at
        FROM query.get_following_by_list(p_list_id) v
        LEFT JOIN public.efp_leaderboard l ON v.following_address = l.address
        WHERE v.tags && p_tags
        ORDER BY  
            (CASE WHEN direction = 'followers' THEN l.followers END) DESC NULLS LAST,
            (CASE WHEN direction = 'earliest' THEN v.updated_at END) ASC NULLS LAST,
            (CASE WHEN direction = 'latest' THEN v.updated_at END) DESC NULLS LAST;
    ELSE
        RETURN QUERY
        SELECT 
            v.efp_list_nft_token_id,
            v.record_version,
            v.record_type,
            v.following_address,
            v.tags,
            v.updated_at
        FROM query.get_following_by_list(p_list_id) v
        LEFT JOIN public.efp_leaderboard l 
        ON v.following_address = l.address
        ORDER BY  
            (CASE WHEN direction = 'followers' THEN l.followers END) DESC NULLS LAST,
            (CASE WHEN direction = 'earliest' THEN v.updated_at END) ASC NULLS LAST,
            (CASE WHEN direction = 'latest' THEN v.updated_at END) DESC NULLS LAST;
    END IF;
END;
$$;




--migrate:down