-- Do shoppers up-vote critical reviews more than positive ones?
SELECT rating,
       count(*)                                           AS reviews,
       round(avg(like_count), 2)                          AS avg_likes,
       round(100 * avg((like_count > 0)::int), 1)         AS pct_with_any_like,
       round(100.0 * sum(like_count) / sum(sum(like_count)) OVER (), 1) AS pct_of_all_likes
FROM lazada.v_review
WHERE has_text
GROUP BY rating
ORDER BY rating;
