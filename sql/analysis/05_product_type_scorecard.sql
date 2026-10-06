-- Ratings by inferred product type (see sql/04_item_type.sql).
SELECT coalesce(t.product_type, 'Unclassified')          AS product_type,
       count(DISTINCT r.item_id)                         AS items,
       count(*)                                          AS reviews,
       round(avg(r.rating), 2)                           AS avg_rating,
       round(100 * avg(r.is_negative::int), 1)           AS negative_pct,
       round(100 * avg(r.has_text::int), 1)              AS pct_with_text,
       rank() OVER (ORDER BY avg(r.is_negative::int) DESC) AS negative_rank
FROM lazada.v_review r
LEFT JOIN lazada.item_type t USING (item_id)
GROUP BY 1
ORDER BY negative_pct DESC;
