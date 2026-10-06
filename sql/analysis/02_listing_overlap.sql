-- How many listing pages each item appeared on, and how many review rows that produced.
WITH pages_per_item AS (
    SELECT item_id, count(*) AS pages
    FROM lazada.item_listing
    GROUP BY item_id
),
raw_rows AS (
    SELECT item_id::bigint AS item_id, count(*) AS raw_rows
    FROM staging.reviews_raw
    GROUP BY item_id
),
unique_reviews AS (
    SELECT item_id, count(*) AS reviews
    FROM lazada.review
    GROUP BY item_id
)
SELECT p.pages                                         AS listing_pages,
       count(*)                                        AS items,
       sum(r.raw_rows)                                 AS raw_rows,
       sum(u.reviews)                                  AS unique_reviews,
       round(sum(r.raw_rows)::numeric / sum(u.reviews), 2) AS raw_rows_per_review
FROM pages_per_item p
JOIN raw_rows r USING (item_id)
JOIN unique_reviews u USING (item_id)
GROUP BY p.pages
ORDER BY p.pages;
