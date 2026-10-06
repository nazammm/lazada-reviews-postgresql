-- Ratings by the platform the review was written on.
SELECT platform,
       count(*)                                    AS reviews,
       round(100.0 * count(*) / sum(count(*)) OVER (), 1) AS pct_of_reviews,
       round(avg(rating), 2)                       AS avg_rating,
       round(100 * avg(is_negative::int), 1)       AS negative_pct
FROM lazada.v_review
GROUP BY platform
ORDER BY reviews DESC;
