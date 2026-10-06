-- Star ratings, with and without written text.
SELECT rating,
       count(*)                                                    AS reviews,
       round(100.0 * count(*) / sum(count(*)) OVER (), 1)          AS pct_of_reviews,
       round(100.0 * avg(has_text::int), 1)                        AS pct_with_text
FROM lazada.v_review
GROUP BY rating
ORDER BY rating;
