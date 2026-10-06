-- Schema for the Lazada Indonesia review data.
--
-- staging  : the CSV exactly as downloaded, every column as text.
-- lazada   : cleaned, deduplicated tables used by the analysis queries.

DROP SCHEMA IF EXISTS staging CASCADE;
DROP SCHEMA IF EXISTS lazada CASCADE;
CREATE SCHEMA staging;
CREATE SCHEMA lazada;

CREATE TABLE staging.reviews_raw (
    item_id          text,
    category         text,
    reviewer_name    text,
    rating           text,
    original_rating  text,
    review_title     text,
    review_content   text,
    like_count       text,
    up_votes         text,
    down_votes       text,
    helpful          text,
    relevance_score  text,
    bought_date      text,
    client_type      text,
    retrieved_date   text
);

-- The scraper walked five category listing pages. The same item can appear on
-- several of them, so a listing page is not a product category in the strict sense.
CREATE TABLE lazada.listing_page (
    listing_page_id  smallint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    slug             text NOT NULL UNIQUE,
    label            text NOT NULL
);

CREATE TABLE lazada.item (
    item_id  bigint PRIMARY KEY
);

CREATE TABLE lazada.item_listing (
    item_id          bigint   NOT NULL REFERENCES lazada.item,
    listing_page_id  smallint NOT NULL REFERENCES lazada.listing_page,
    PRIMARY KEY (item_id, listing_page_id)
);

CREATE TABLE lazada.platform (
    platform_code  text PRIMARY KEY,
    label          text NOT NULL
);

CREATE TABLE lazada.review (
    review_id        bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    -- md5 of the fields that identify one review. The reviewer name goes into the
    -- hash so duplicates can be found, but it is not stored anywhere.
    review_key       char(32) NOT NULL UNIQUE,
    item_id          bigint   NOT NULL REFERENCES lazada.item,
    rating           smallint NOT NULL CHECK (rating BETWEEN 1 AND 5),
    title            text,
    content          text,
    like_count       integer  NOT NULL CHECK (like_count >= 0),
    down_votes       integer  NOT NULL CHECK (down_votes >= 0),
    relevance_score  numeric(6, 2),
    bought_on        date,
    platform_code    text REFERENCES lazada.platform,
    retrieved_on     date     NOT NULL
);

CREATE INDEX review_item_idx      ON lazada.review (item_id);
CREATE INDEX review_bought_on_idx ON lazada.review (bought_on);
CREATE INDEX review_rating_idx    ON lazada.review (rating);
