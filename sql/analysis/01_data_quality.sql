-- What the raw scrape looks like next to the cleaned tables.
SELECT metric, value
FROM (
    VALUES
        (1, 'Rows in the raw CSV',                 (SELECT count(*) FROM staging.reviews_raw)::text),
        (2, 'Unique reviews after deduplication',  (SELECT count(*) FROM lazada.review)::text),
        (3, 'Items',                               (SELECT count(*) FROM lazada.item)::text),
        (4, 'Items listed on more than one page',  (SELECT count(*) FROM (SELECT item_id FROM lazada.item_listing GROUP BY item_id HAVING count(*) > 1) x)::text),
        (5, 'Reviews with written text',           (SELECT count(*) FROM lazada.review WHERE content IS NOT NULL)::text),
        (6, 'Reviews without a purchase date',     (SELECT count(*) FROM lazada.review WHERE bought_on IS NULL)::text),
        (7, 'Raw rows with a like count of -1',    (SELECT count(*) FROM staging.reviews_raw WHERE like_count = '-1')::text),
        (8, 'First purchase date',                 (SELECT min(bought_on) FROM lazada.review)::text),
        (9, 'Last purchase date',                  (SELECT max(bought_on) FROM lazada.review)::text)
) AS m (sort_order, metric, value)
ORDER BY sort_order;
