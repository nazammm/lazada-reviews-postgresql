-- Review volume and the share of 1-2 star reviews per purchase quarter.
-- Quarters with fewer than 300 reviews are left out; their shares swing too much.
WITH quarterly AS (
    SELECT date_trunc('quarter', bought_on)::date AS quarter,
           count(*)                               AS reviews,
           avg(rating)                            AS avg_rating,
           avg(is_negative::int)                  AS negative_share
    FROM lazada.v_review
    WHERE bought_on IS NOT NULL
    GROUP BY 1
)
SELECT quarter,
       reviews,
       round(avg_rating, 2)                                          AS avg_rating,
       round(100 * negative_share, 1)                                AS negative_pct,
       round(100 * avg(negative_share) OVER (
           ORDER BY quarter ROWS BETWEEN 3 PRECEDING AND CURRENT ROW), 1) AS negative_pct_4q_avg
FROM quarterly
WHERE reviews >= 300
ORDER BY quarter;
