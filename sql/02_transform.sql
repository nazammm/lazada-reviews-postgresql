-- Move the raw scrape into the cleaned tables.
-- Run after the CSV has been copied into staging.reviews_raw.

-- Purchase dates are written with Indonesian month abbreviations ("17 Agu 2018").
CREATE OR REPLACE FUNCTION staging.parse_id_date(txt text)
RETURNS date
LANGUAGE sql
IMMUTABLE
AS $$
    SELECT to_date(
        split_part(txt, ' ', 1) || ' ' ||
        CASE split_part(txt, ' ', 2)
            WHEN 'Mei' THEN 'May'
            WHEN 'Agu' THEN 'Aug'
            WHEN 'Okt' THEN 'Oct'
            WHEN 'Des' THEN 'Dec'
            ELSE split_part(txt, ' ', 2)
        END || ' ' ||
        split_part(txt, ' ', 3),
        'DD Mon YYYY'
    )
    WHERE nullif(trim(txt), '') IS NOT NULL
$$;

INSERT INTO lazada.listing_page (slug, label) VALUES
    ('beli-harddisk-eksternal', 'External hard drives'),
    ('jual-flash-drives',       'Flash drives'),
    ('beli-smart-tv',           'Smart TVs'),
    ('shop-televisi-digital',   'Digital TVs'),
    ('beli-laptop',             'Laptops');

INSERT INTO lazada.platform (platform_code, label) VALUES
    ('androidApp', 'Android app'),
    ('iosApp',     'iOS app'),
    ('mobile-app', 'Mobile app, OS not recorded'),
    ('mobile',     'Mobile browser'),
    ('desktop',    'Desktop browser');

INSERT INTO lazada.item (item_id)
SELECT DISTINCT item_id::bigint
FROM staging.reviews_raw;

INSERT INTO lazada.item_listing (item_id, listing_page_id)
SELECT DISTINCT r.item_id::bigint, lp.listing_page_id
FROM staging.reviews_raw r
JOIN lazada.listing_page lp ON lp.slug = r.category;

-- The same review was scraped once per listing page the item appeared on.
-- Identical reviews collapse to one row through review_key.
INSERT INTO lazada.review (
    review_key, item_id, rating, title, content, like_count, down_votes,
    relevance_score, bought_on, platform_code, retrieved_on
)
SELECT DISTINCT ON (review_key)
    review_key,
    item_id::bigint,
    rating::smallint,
    nullif(trim(review_title), ''),
    nullif(trim(review_content), ''),
    greatest(like_count::integer, 0),   -- a handful of rows carry -1
    greatest(down_votes::integer, 0),
    relevance_score::numeric,
    staging.parse_id_date(bought_date),
    client_type,
    retrieved_date::date
FROM (
    SELECT r.*,
           md5(concat_ws('|', item_id, reviewer_name, rating, review_title,
                         review_content, bought_date, like_count)) AS review_key
    FROM staging.reviews_raw r
) keyed
ORDER BY review_key;

ANALYZE lazada.item;
ANALYZE lazada.item_listing;
ANALYZE lazada.review;
