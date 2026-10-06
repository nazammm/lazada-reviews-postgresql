-- Views shared by the analysis queries.

CREATE OR REPLACE VIEW lazada.v_review AS
SELECT
    r.review_id,
    r.item_id,
    r.rating,
    r.rating <= 2                       AS is_negative,
    r.content IS NOT NULL               AS has_text,
    lower(r.content)                    AS content_lower,
    r.like_count,
    r.bought_on,
    date_trunc('month', r.bought_on)::date AS bought_month,
    p.label                             AS platform
FROM lazada.review r
LEFT JOIN lazada.platform p USING (platform_code);

-- Items that appear on exactly one listing page. Only these can be compared by
-- product type without double counting.
CREATE OR REPLACE VIEW lazada.v_item_single_listing AS
SELECT il.item_id, lp.label AS listing
FROM lazada.item_listing il
JOIN lazada.listing_page lp USING (listing_page_id)
WHERE il.item_id IN (
    SELECT item_id
    FROM lazada.item_listing
    GROUP BY item_id
    HAVING count(*) = 1
);
