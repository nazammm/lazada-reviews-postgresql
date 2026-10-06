-- What 1-2 star reviews complain about, by product type.
-- A review can mention several themes, so shares do not add up to 100.
WITH theme (theme, pattern) AS (
    VALUES
        ('Fake or smaller capacity', '\m(palsu|kw|fake|abal|kapasitas|tidak asli|ga asli|gak asli|bukan asli|ori)'),
        ('Broken or not working',    '\m(rusak|cacat|mati|error|tidak berfungsi|ga berfungsi|gak berfungsi|tidak bisa|ga bisa|gak bisa|tdk bisa|pecah|retak)'),
        ('Not as described',         '\m(tidak sesuai|ga sesuai|gak sesuai|tdk sesuai|beda|berbeda|salah kirim|salah barang)'),
        ('Slow delivery',            '\m(lama|lambat|telat|terlambat|belum sampai|pengiriman|kurir)'),
        ('Packaging',                '\m(packing|kemasan|bungkus|dus|kardus|bubble)'),
        ('Seller, refund, warranty', '\m(penjual|seller|respon|komplain|retur|refund|pengembalian|garansi)')
),
negative_text AS (
    SELECT r.review_id,
           coalesce(t.product_type, 'Unclassified') AS product_type,
           r.content_lower
    FROM lazada.v_review r
    LEFT JOIN lazada.item_type t USING (item_id)
    WHERE r.is_negative AND r.has_text
),
totals AS (
    SELECT product_type, count(*) AS negative_reviews
    FROM negative_text
    GROUP BY product_type
)
SELECT n.product_type,
       th.theme,
       count(*)                                          AS reviews_mentioning,
       tot.negative_reviews,
       round(100.0 * count(*) / tot.negative_reviews, 1) AS pct_of_negative
FROM negative_text n
JOIN theme th ON n.content_lower ~ th.pattern
JOIN totals tot USING (product_type)
GROUP BY n.product_type, th.theme, tot.negative_reviews
ORDER BY n.product_type, pct_of_negative DESC;
