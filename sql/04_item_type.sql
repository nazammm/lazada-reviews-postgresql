-- Infer what each item is from the words buyers use in its reviews.
--
-- The listing pages cannot tell product types apart (most items sit on several
-- pages), so each item gets the product type its reviewers mention most often.
-- An item is typed only when at least two reviews point the same way and that
-- type accounts for 60% or more of the matches. Everything else stays unclassified.

DROP TABLE IF EXISTS lazada.item_type;

CREATE TABLE lazada.item_type AS
WITH product_term (product_type, pattern) AS (
    VALUES
        ('Flash drive',         '\m(flashdisk|flash disk|flasdisk|flashdis|fd|usb|otg)\M'),
        ('External hard drive', '\m(hardisk|harddisk|hard disk|hardis|hdd|ssd|hd external|hdd external)\M'),
        ('TV',                  '\m(tv|televisi|tivi|led tv|smart tv|remote|channel|siaran|antena)\M'),
        ('Laptop',              '\m(laptop|notebook|leptop|keyboard|touchpad|charger laptop)\M')
),
mentions AS (
    SELECT r.item_id, t.product_type, count(*) AS n_reviews
    FROM lazada.review r
    JOIN product_term t ON lower(r.content) ~ t.pattern
    GROUP BY r.item_id, t.product_type
),
ranked AS (
    SELECT item_id,
           product_type,
           n_reviews,
           n_reviews::numeric / sum(n_reviews) OVER (PARTITION BY item_id) AS share,
           row_number() OVER (PARTITION BY item_id ORDER BY n_reviews DESC) AS rn
    FROM mentions
)
SELECT item_id, product_type, n_reviews AS supporting_reviews, round(share, 2) AS share
FROM ranked
WHERE rn = 1
  AND n_reviews >= 2
  AND share >= 0.6;

ALTER TABLE lazada.item_type ADD PRIMARY KEY (item_id);
ALTER TABLE lazada.item_type ADD FOREIGN KEY (item_id) REFERENCES lazada.item;
