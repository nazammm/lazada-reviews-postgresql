-- Items whose negative share is high even after allowing for sample size.
-- Ranking on the raw share favours items with a handful of reviews, so items are
-- ordered by the lower bound of a 95% Wilson interval on their negative share.
WITH item_stats AS (
    SELECT item_id,
           count(*)                     AS reviews,
           sum(is_negative::int)        AS negative
    FROM lazada.v_review
    GROUP BY item_id
    HAVING count(*) >= 100
),
scored AS (
    SELECT item_id,
           reviews,
           negative,
           negative::numeric / reviews AS p,
           (negative::numeric / reviews + 1.96 ^ 2 / (2 * reviews)
              - 1.96 * sqrt((negative::numeric / reviews * (1 - negative::numeric / reviews)
                             + 1.96 ^ 2 / (4 * reviews)) / reviews))
           / (1 + 1.96 ^ 2 / reviews)   AS p_lower
    FROM item_stats
)
SELECT s.item_id,
       coalesce(t.product_type, 'Unclassified')   AS product_type,
       s.reviews,
       s.negative,
       round(100 * s.p, 1)                        AS negative_pct,
       round(100 * s.p_lower, 1)                  AS negative_pct_lower_95,
       ntile(10) OVER (ORDER BY s.p_lower)        AS decile
FROM scored s
LEFT JOIN lazada.item_type t USING (item_id)
ORDER BY s.p_lower DESC
LIMIT 20;
