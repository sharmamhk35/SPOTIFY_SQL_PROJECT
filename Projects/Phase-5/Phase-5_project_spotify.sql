-- ================================
-- Project Phase-5: SpotifyDB (MySQL)
-- 100 Queries across SQL concepts
-- Realistic scenario: Spotify-like streaming DB
-- ================================

-- ================================
-- Section 1: DDL (10 queries)
-- Create/Alter/Drop tables and constraints
-- ================================

-- 1. Create an audit table for schema changes
CREATE TABLE IF NOT EXISTS schema_audit (
  audit_id INT AUTO_INCREMENT PRIMARY KEY,
  change_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  change_by VARCHAR(100),
  change_description TEXT
);

-- 2. Create a simple analytics table for daily active users
CREATE TABLE IF NOT EXISTS daily_active_users (
  day_date DATE PRIMARY KEY,
  active_users INT DEFAULT 0
);

-- 3. Alter users: add last_seen timestamp column
ALTER TABLE users ADD COLUMN last_seen TIMESTAMP NULL DEFAULT NULL;

-- 4. Create a table for artist_genres linking (many-to-many)
CREATE TABLE IF NOT EXISTS artist_genres (
  artist_genre_id INT PRIMARY KEY AUTO_INCREMENT,
  artist_id INT NOT NULL,
  genre_id INT NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_ag_artist FOREIGN KEY (artist_id) REFERENCES artists(artist_id) ON DELETE CASCADE
);

-- 5. Create table for promotional_campaigns
CREATE TABLE IF NOT EXISTS promotional_campaigns (
  campaign_id INT PRIMARY KEY AUTO_INCREMENT,
  advertiser_id INT NOT NULL,
  campaign_name VARCHAR(150),
  start_date DATE,
  end_date DATE,
  budget DECIMAL(12,2) DEFAULT 0,
  FOREIGN KEY (advertiser_id) REFERENCES advertisers(advertiser_id) ON DELETE SET NULL
);

-- 6. Add index on listening_history for played_at to speed time queries
CREATE INDEX idx_listening_played_at ON listening_history(played_at);

-- 7. Create a simple cached table for top_tracks (to be refreshed periodically)
CREATE TABLE IF NOT EXISTS top_tracks_cache (
  cache_date DATE PRIMARY KEY,
  track_ids TEXT, -- comma-separated list
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 8. Create temporary import table for bulk uploads (no PK required)
CREATE TEMPORARY TABLE tmp_bulk_tracks_import (
  import_id INT AUTO_INCREMENT PRIMARY KEY,
  track_title VARCHAR(255),
  album_id INT,
  duration_seconds INT
);

-- 9. Drop an obsolete table if present (cleanup)
DROP TABLE IF EXISTS old_user_metrics;

-- 10. Rename column example: change playlists.description to playlists.long_description (MySQL)
ALTER TABLE playlists CHANGE COLUMN description long_description VARCHAR(500) NULL;

-- ================================
-- Section 2: DML (10 queries)
-- Inserts, Updates, Deletes
-- ================================

-- 11. Insert a new user (sample real data)
INSERT INTO users (user_id, username, email, full_name, password_hash, country, dob, signup_date, is_premium, preferred_lang, phone)
VALUES (301, 'rahul301', 'rahul301@example.com', 'Rahul Sharma', 'hash301', 'India', '1998-05-12', CURRENT_DATE, TRUE, 'en', '9876543210');

-- 12. Bulk-insert sample devices for user 301
INSERT INTO devices (device_id, user_id, device_name, device_type, os, app_version, last_login, is_active, ip_address, location)
VALUES
(301, 301, 'OnePlus 9', 'Mobile', 'Android 11', '9.0.1', NOW(), TRUE, '10.0.0.1', 'Delhi, India'),
(302, 301, 'MBA 2020', 'Laptop', 'macOS Big Sur', '9.0.1', NOW(), TRUE, '10.0.0.2', 'Delhi, India');

-- 13. Update: increase followers for an artist after viral song
UPDATE artists SET followers = followers + 5000 WHERE artist_id = 2;

-- 14. Insert sample playlist for user 301
INSERT INTO playlists (playlist_id, user_id, playlist_name, long_description, created_at, is_public, total_tracks, followers_count, status)
VALUES (301, 301, 'Morning Boost', 'High-energy tracks for mornings', CURRENT_DATE, TRUE, 0, 10, 'Active');

-- 15. Insert sample track and link to album 1
INSERT INTO tracks (track_id, album_id, track_title, duration_seconds, track_number, genre, language, release_date, popularity_score, is_explicit)
VALUES (301, 1, 'Sunrise Drive', 210, 11, 'Pop', 'English', '2023-07-01', 78, FALSE);

-- 16. Update playlist total_tracks after adding track
INSERT INTO playlist_tracks (playlist_track_id, playlist_id, track_id, added_by, added_at, sequence_order, is_favorite, play_count, status, last_played)
VALUES (301, 301, 301, 301, NOW(), 1, TRUE, 0, 'Active', NULL);
UPDATE playlists SET total_tracks = total_tracks + 1 WHERE playlist_id = 301;

-- 17. Delete a stale temp record from tmp_bulk_tracks_import
DELETE FROM tmp_bulk_tracks_import WHERE import_id = 1;

-- 18. Insert subscription for user 301
INSERT INTO subscriptions (subscription_id, user_id, plan_name, start_date, end_date, is_active, renewal_type, price, payment_method, last_payment_date)
VALUES (301, 301, 'Premium Monthly', CURRENT_DATE, DATE_ADD(CURRENT_DATE, INTERVAL 30 DAY), TRUE, 'Auto', 9.99, 'UPI', CURRENT_DATE);

-- 19. Update payments: mark failed payments older than 30 days as 'Failed-Archived'
UPDATE payments SET status = 'Failed-Archived' WHERE status = 'Pending' AND payment_date < DATE_SUB(CURDATE(), INTERVAL 30 DAY);

-- 20. Delete test playlist created before 2020
DELETE FROM playlists WHERE created_at < '2020-01-01' AND user_id = 9999;

-- ================================
-- Section 3: DQL (10 queries)
-- SELECT with filters, ORDER BY, GROUP BY
-- ================================

-- 21. Select all premium users ordered by signup date (newest first)
SELECT user_id, username, email, signup_date FROM users WHERE is_premium = TRUE ORDER BY signup_date DESC LIMIT 50;

-- 22. Top 10 tracks by popularity score
SELECT track_id, track_title, popularity_score FROM tracks ORDER BY popularity_score DESC LIMIT 10;

-- 23. Count songs per album (album summary)
SELECT al.album_id, al.album_name, COUNT(t.track_id) AS track_count FROM albums al LEFT JOIN tracks t ON t.album_id = al.album_id GROUP BY al.album_id ORDER BY track_count DESC;

-- 24. List playlists with more than 1000 followers
SELECT playlist_id, playlist_name, followers_count FROM playlists WHERE followers_count > 1000 ORDER BY followers_count DESC;

-- 25. Recent 20 listening_history entries with user and track names
SELECT lh.history_id, u.username, t.track_title, lh.played_at FROM listening_history lh JOIN users u ON u.user_id = lh.user_id JOIN tracks t ON t.track_id = lh.track_id ORDER BY lh.played_at DESC LIMIT 20;

-- 26. Podcasts with total episodes and average plays per episode
SELECT p.podcast_id, p.title, COUNT(pe.episode_id) AS episodes, AVG(pe.plays_count) AS avg_plays FROM podcasts p LEFT JOIN podcast_episodes pe ON pe.podcast_id = p.podcast_id GROUP BY p.podcast_id;

-- 27. Users and number of devices they use, sorted descending
SELECT u.user_id, u.username, COUNT(d.device_id) AS device_count FROM users u LEFT JOIN devices d ON d.user_id = u.user_id GROUP BY u.user_id ORDER BY device_count DESC LIMIT 50;

-- 28. Frequently skipped tracks (is_skipped true count)
SELECT t.track_id, t.track_title, SUM(CASE WHEN lh.is_skipped THEN 1 ELSE 0 END) AS skip_count FROM tracks t LEFT JOIN listening_history lh ON lh.track_id = t.track_id GROUP BY t.track_id ORDER BY skip_count DESC LIMIT 20;

-- 29. Top advertisers by ad revenue
SELECT adv.advertiser_id, adv.company_name, SUM(ap.revenue_generated) AS total_revenue FROM advertisers adv JOIN ad_plays ap ON ap.advertiser_id = adv.advertiser_id GROUP BY adv.advertiser_id ORDER BY total_revenue DESC LIMIT 10;

-- 30. Concerts with sold tickets > 100 and total sales
SELECT c.concert_id, c.concert_name, COUNT(t.ticket_id) AS sold, SUM(t.price) AS sales FROM concerts c LEFT JOIN tickets t ON t.concert_id = c.concert_id GROUP BY c.concert_id HAVING sold > 100 ORDER BY sales DESC;

-- ================================
-- Section 4: Clauses & Operators (10 queries)
-- WHERE, BETWEEN, LIKE, IN, ANY, ALL, AND/OR/NOT
-- ================================

-- 31. Users in India or UK who are premium
SELECT user_id, username, country FROM users WHERE (country = 'India' OR country = 'UK') AND is_premium = TRUE;

-- 32. Tracks released between two dates
SELECT track_id, track_title, release_date FROM tracks WHERE release_date BETWEEN '2022-01-01' AND '2023-12-31';

-- 33. Search for tracks with 'love' or 'heart' in title (case-insensitive)
SELECT track_id, track_title FROM tracks WHERE LOWER(track_title) LIKE '%love%' OR LOWER(track_title) LIKE '%heart%';

-- 34. Playlists owned by users 1,2,3 (IN operator)
SELECT playlist_id, playlist_name, user_id FROM playlists WHERE user_id IN (1,2,3);

-- 35. Tracks with popularity greater than ANY album average popularity
SELECT t.track_id, t.track_title FROM tracks t WHERE t.popularity_score > ANY (SELECT AVG(t2.popularity_score) FROM tracks t2 GROUP BY t2.album_id);

-- 36. Users who are not premium and have no payments (NOT EXISTS)
SELECT u.user_id, u.username FROM users u WHERE NOT EXISTS (SELECT 1 FROM payments p WHERE p.user_id = u.user_id) AND NOT u.is_premium;

-- 37. Use IS NULL to find tracks without album assignment
SELECT track_id, track_title FROM tracks WHERE album_id IS NULL;

-- 38. Use COALESCE to display user phone or fallback
SELECT user_id, username, COALESCE(phone, 'NoPhone') AS phone_display FROM users LIMIT 20;

-- 39. Complex logical condition example: popular explicit tracks
SELECT track_id, track_title FROM tracks WHERE is_explicit = TRUE AND popularity_score >= 80 AND duration_seconds <= 300;

-- 40. Use LIKE with wildcard at start and end to find artist names containing 'The'
SELECT artist_id, stage_name FROM artists WHERE stage_name LIKE '%The%';

-- ================================
-- Section 5: Constraints & Cascades (10 queries)
-- PK, FK, ON DELETE/UPDATE CASCADE and CHECKs
-- ================================

-- 41. Add a foreign key constraint between album_artists and artists with cascade on delete
ALTER TABLE album_artists
ADD CONSTRAINT fk_albumartists_artist FOREIGN KEY (artist_id) REFERENCES artists(artist_id) ON DELETE CASCADE ON UPDATE CASCADE;

-- 42. Add a foreign key constraint between album_artists and albums with cascade on delete
ALTER TABLE album_artists
ADD CONSTRAINT fk_albumartists_album FOREIGN KEY (album_id) REFERENCES albums(album_id) ON DELETE CASCADE ON UPDATE CASCADE;

-- 43. Add check constraint to ensure price non-negative (MySQL 8.0+)
ALTER TABLE tickets ADD CONSTRAINT chk_ticket_price_nonneg CHECK (price >= 0);

-- 44. Add unique constraint on advertisers.email
ALTER TABLE advertisers ADD CONSTRAINT uq_advertiser_email UNIQUE (email);

-- 45. Add composite unique on (playlist_id, track_id) to prevent duplicate track entries
ALTER TABLE playlist_tracks ADD CONSTRAINT uq_playlist_track UNIQUE (playlist_id, track_id);

-- 46. Add FK from playlist_tracks.added_by to users with ON DELETE SET NULL
ALTER TABLE playlist_tracks
ADD CONSTRAINT fk_pt_addedby_user FOREIGN KEY (added_by) REFERENCES users(user_id) ON DELETE SET NULL ON UPDATE CASCADE;

-- 47. Ensure subscription plan names are unique
ALTER TABLE subscription_plans ADD CONSTRAINT uq_plan_name UNIQUE (plan_name);

-- 48. Add FK for payments.subscription_id to subscriptions with ON DELETE SET NULL
ALTER TABLE payments
ADD CONSTRAINT fk_payments_subscription FOREIGN KEY (subscription_id) REFERENCES subscriptions(subscription_id) ON DELETE SET NULL ON UPDATE CASCADE;

-- 49. Add check constraint to ensure rating within 0-5 for reviews
ALTER TABLE reviews ADD CONSTRAINT chk_review_rating CHECK (rating >= 0 AND rating <= 5);

-- 50. Create FK user_library.user_id -> users.user_id with cascade on delete
ALTER TABLE user_library
ADD CONSTRAINT fk_userlibrary_user FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE ON UPDATE CASCADE;

-- ================================
-- Section 6: Joins (10 queries)
-- INNER, LEFT, RIGHT, FULL (simulated), SELF
-- ================================

-- 51. INNER JOIN: tracks with album and primary artist
SELECT t.track_id, t.track_title, al.album_name, ar.stage_name
FROM tracks t
INNER JOIN albums al ON t.album_id = al.album_id
INNER JOIN album_artists aa ON aa.album_id = al.album_id AND aa.role = 'Primary'
INNER JOIN artists ar ON ar.artist_id = aa.artist_id
LIMIT 50;

-- 52. LEFT JOIN: users and their subscriptions (include users without subscriptions)
SELECT u.user_id, u.username, s.plan_name FROM users u LEFT JOIN subscriptions s ON s.user_id = u.user_id;

-- 53. RIGHT JOIN (MySQL): playlists and their owner info (show all playlists)
SELECT p.playlist_id, p.playlist_name, u.username FROM users u RIGHT JOIN playlists p ON p.user_id = u.user_id;

-- 54. FULL JOIN simulated with UNION: advertisers and ad_plays
SELECT adv.advertiser_id, adv.company_name, ap.ad_play_id FROM advertisers adv LEFT JOIN ad_plays ap ON ap.advertiser_id = adv.advertiser_id
UNION
SELECT adv.advertiser_id, adv.company_name, ap.ad_play_id FROM advertisers adv RIGHT JOIN ad_plays ap ON ap.advertiser_id = adv.advertiser_id;

-- 55. SELF JOIN: find users who follow other users and list both sides
SELECT u1.user_id AS user, u1.username AS user_name, u2.user_id AS follower, u2.username AS follower_name
FROM user_followers uf
JOIN users u1 ON u1.user_id = uf.user_id
JOIN users u2 ON u2.user_id = uf.follower_user_id
LIMIT 50;

-- 56. JOIN with aggregation: playlists with top contributor (user who added most tracks)
SELECT p.playlist_id, p.playlist_name, sub.top_user, sub.track_count FROM playlists p
LEFT JOIN (
  SELECT playlist_id, added_by AS top_user, COUNT(*) AS track_count
  FROM playlist_tracks GROUP BY playlist_id, added_by ORDER BY track_count DESC
) sub ON sub.playlist_id = p.playlist_id LIMIT 50;

-- 57. Multi-table join: tickets -> concerts -> artists
SELECT t.ticket_id, u.username, c.concert_name, ar.stage_name
FROM tickets t
JOIN users u ON u.user_id = t.user_id
JOIN concerts c ON c.concert_id = t.concert_id
JOIN artists ar ON ar.artist_id = c.artist_id;

-- 58. LEFT JOIN to find tracks not in any playlist
SELECT t.track_id, t.track_title FROM tracks t LEFT JOIN playlist_tracks pt ON pt.track_id = t.track_id WHERE pt.playlist_track_id IS NULL;

-- 59. JOIN using derived table: top 10 playlists by followers and their track counts
SELECT top.playlist_id, top.playlist_name, COALESCE(pc.track_count,0) AS tracks FROM
(SELECT playlist_id, playlist_name FROM playlists ORDER BY followers_count DESC LIMIT 10) top
LEFT JOIN (SELECT playlist_id, COUNT(*) AS track_count FROM playlist_tracks GROUP BY playlist_id) pc ON pc.playlist_id = top.playlist_id;

-- 60. INNER JOIN to get podcast episodes with host names via episode_hosts
SELECT pe.episode_id, pe.title, eh.host_name FROM podcast_episodes pe INNER JOIN episode_hosts eh ON eh.episode_id = pe.episode_id;

-- ================================
-- Section 7: Subqueries (10 queries)
-- Nested queries, correlated subqueries
-- ================================

-- 61. Correlated subquery: tracks more popular than album average
SELECT t.track_id, t.track_title, t.popularity_score
FROM tracks t
WHERE t.popularity_score > (SELECT AVG(t2.popularity_score) FROM tracks t2 WHERE t2.album_id = t.album_id);

-- 62. IN subquery: users who have playlists with >20 tracks
SELECT DISTINCT u.user_id, u.username FROM users u WHERE u.user_id IN (SELECT p.user_id FROM playlists p WHERE p.total_tracks > 20);

-- 63. EXISTS correlated: artists with albums released after 2021
SELECT ar.artist_id, ar.stage_name FROM artists ar WHERE EXISTS (SELECT 1 FROM album_artists aa JOIN albums al ON al.album_id = aa.album_id WHERE aa.artist_id = ar.artist_id AND al.release_date > '2021-01-01');

-- 64. Scalar subquery in SELECT: last payment amount per user
SELECT u.user_id, u.username, (SELECT p.amount FROM payments p WHERE p.user_id = u.user_id ORDER BY p.payment_date DESC LIMIT 1) AS last_payment FROM users u LIMIT 50;

-- 65. Subquery in FROM: users with their listen counts
SELECT sub.user_id, sub.listen_count FROM (SELECT user_id, COUNT(*) AS listen_count FROM listening_history GROUP BY user_id) sub ORDER BY listen_count DESC LIMIT 20;

-- 66. NOT IN: tracks not present in song_credits (no contributors)
SELECT t.track_id, t.track_title FROM tracks t WHERE t.track_id NOT IN (SELECT track_id FROM song_credits);

-- 67. Nested aggregation: albums whose total streams exceed average album streams
SELECT al.album_id, al.album_name FROM albums al WHERE al.streams > (SELECT AVG(streams) FROM albums);

-- 68. Subquery with HAVING: users who saved more than 10 library items
SELECT user_id FROM user_library GROUP BY user_id HAVING COUNT(*) > 10;

-- 69. Subquery with ANY: find tracks whose popularity greater than ANY album average (at least greater than one)
SELECT t.track_id, t.track_title FROM tracks t WHERE t.popularity_score > ANY (SELECT AVG(popularity_score) FROM tracks GROUP BY album_id);

-- 70. Use correlated EXISTS to find playlists that contain a track by a particular artist (artist_id = 3)
SELECT p.playlist_id, p.playlist_name FROM playlists p WHERE EXISTS (SELECT 1 FROM playlist_tracks pt JOIN tracks tr ON tr.track_id = pt.track_id JOIN album_artists aa ON aa.album_id = tr.album_id WHERE pt.playlist_id = p.playlist_id AND aa.artist_id = 3);

-- ================================
-- Section 8: Functions (10 queries)
-- Aggregate & scalar built-in examples
-- ================================

-- 71. Aggregate: total revenue from payments
SELECT SUM(amount) AS total_revenue FROM payments;

-- 72. Aggregate: average track duration
SELECT AVG(duration_seconds) AS avg_duration_sec FROM tracks;

-- 73. COUNT + GROUP BY: number of users per country
SELECT country, COUNT(*) AS users FROM users GROUP BY country ORDER BY users DESC;

-- 74. MIN/MAX: shortest and longest track durations
SELECT MIN(duration_seconds) AS shortest, MAX(duration_seconds) AS longest FROM tracks;

-- 75. String functions: uppercase artist names
SELECT artist_id, UPPER(stage_name) AS artist_caps FROM artists LIMIT 20;

-- 76. DATE functions: days since user's last login
SELECT user_id, username, DATEDIFF(CURRENT_DATE, DATE(last_seen)) AS days_since_last_seen FROM users WHERE last_seen IS NOT NULL LIMIT 20;

-- 77. CONCAT and formatting: user contact card
SELECT user_id, CONCAT(full_name, ' <', email, '>') AS contact_card FROM users LIMIT 20;

-- 78. ROUND and arithmetic: monthly revenue rounded
SELECT DATE_FORMAT(payment_date, '%Y-%m') AS ym, ROUND(SUM(amount),2) AS revenue FROM payments GROUP BY ym ORDER BY ym DESC LIMIT 12;

-- 79. COALESCE example: show preferred language or 'en'
SELECT user_id, username, COALESCE(preferred_language, preferred_lang, 'en') AS lang FROM users LIMIT 20;

-- 80. JSON aggregation example (MySQL): list track IDs in playlists as JSON array
SELECT playlist_id, JSON_ARRAYAGG(track_id) AS tracks_json FROM playlist_tracks GROUP BY playlist_id LIMIT 10;

-- ================================
-- Section 9: Views & CTE (10 queries)
-- Create/use views and Common Table Expressions (CTE)
-- ================================

-- 81. Create view: v_premium_revenue summarizing payments by premium users
CREATE OR REPLACE VIEW v_premium_revenue AS
SELECT u.user_id, u.username, SUM(p.amount) AS lifetime_spend
FROM users u JOIN payments p ON p.user_id = u.user_id
WHERE u.is_premium = TRUE
GROUP BY u.user_id;

-- 82. Use view: top 10 premium spenders
SELECT * FROM v_premium_revenue ORDER BY lifetime_spend DESC LIMIT 10;

-- 83. Create view: v_albums_streams for quick album lookups
CREATE OR REPLACE VIEW v_albums_streams AS SELECT album_id, album_name, streams FROM albums;

-- 84. CTE: recursive example for a simple hierarchical data (simulate user referral chain) - uses hypothetical referrals table
WITH RECURSIVE referrals_cte (user_id, referrer_id, level) AS (
  SELECT user_id, referrer_id, 1 FROM user_referrals WHERE referrer_id IS NOT NULL
  UNION ALL
  SELECT ur.user_id, ur.referrer_id, level + 1 FROM user_referrals ur JOIN referrals_cte r ON ur.referrer_id = r.user_id WHERE level < 5
)
SELECT * FROM referrals_cte LIMIT 50;

-- 85. CTE: top 10 listeners in last 30 days
WITH last30 AS (
  SELECT user_id, COUNT(*) AS listens FROM listening_history WHERE played_at >= DATE_SUB(NOW(), INTERVAL 30 DAY) GROUP BY user_id
)
SELECT u.user_id, u.username, l.listens FROM last30 l JOIN users u ON u.user_id = l.user_id ORDER BY l.listens DESC LIMIT 10;

-- 86. Create view: v_top_podcasts
CREATE OR REPLACE VIEW v_top_podcasts AS
SELECT p.podcast_id, p.title, SUM(pe.plays_count) AS total_plays FROM podcasts p JOIN podcast_episodes pe ON pe.podcast_id = p.podcast_id GROUP BY p.podcast_id HAVING total_plays > 1000;

-- 87. Use view with filter
SELECT * FROM v_top_podcasts WHERE total_plays > 5000 ORDER BY total_plays DESC;

-- 88. CTE: compute album average popularity and show albums above average
WITH album_avg AS (
  SELECT al.album_id, AVG(t.popularity_score) AS avg_pop FROM albums al JOIN tracks t ON t.album_id = al.album_id GROUP BY al.album_id
), overall AS (SELECT AVG(avg_pop) AS overall_avg FROM album_avg)
SELECT a.album_id, a.album_name, aa.avg_pop FROM album_avg aa JOIN albums a ON a.album_id = aa.album_id CROSS JOIN overall WHERE aa.avg_pop > overall.overall_avg ORDER BY aa.avg_pop DESC;

-- 89. Create view combining playlists & stats
CREATE OR REPLACE VIEW v_playlist_summary AS SELECT p.playlist_id, p.playlist_name, p.followers_count, COALESCE(pt.count,0) AS track_count FROM playlists p LEFT JOIN (SELECT playlist_id, COUNT(*) AS count FROM playlist_tracks GROUP BY playlist_id) pt ON pt.playlist_id = p.playlist_id;

-- 90. Use view: get playlists needing attention (many followers but few tracks)
SELECT * FROM v_playlist_summary WHERE followers_count > 1000 AND track_count < 5;

-- ================================
-- Section 10: Stored Procedures (5 queries)
-- Basic CRUD operations as procedures
-- ================================

DELIMITER $$

-- 91. SP: Add a new user safely
CREATE PROCEDURE sp_add_user(IN p_username VARCHAR(100), IN p_email VARCHAR(150), IN p_fullname VARCHAR(150), IN p_country VARCHAR(50))
BEGIN
  INSERT INTO users(user_id, username, email, full_name, password_hash, country, dob, signup_date, is_premium, preferred_lang)
  VALUES ((SELECT IFNULL(MAX(user_id),0)+1 FROM users), p_username, p_email, p_fullname, 'pwdhash', p_country, NULL, CURRENT_DATE, FALSE, 'en');
END$$

-- 92. SP: Update user phone
CREATE PROCEDURE sp_update_user_phone(IN p_user INT, IN p_phone VARCHAR(20))
BEGIN
  UPDATE users SET phone = p_phone, last_seen = NOW() WHERE user_id = p_user;
END$$

-- 93. SP: Delete a user's library items (careful)
CREATE PROCEDURE sp_clear_user_library(IN p_user INT)
BEGIN
  DELETE FROM user_library WHERE user_id = p_user;
END$$

-- 94. SP: Add payment for subscription and activate it (transaction inside SP)
CREATE PROCEDURE sp_add_payment_activate(IN p_sub INT, IN p_user INT, IN p_amount DECIMAL(7,2))
BEGIN
  START TRANSACTION;
    INSERT INTO payments(payment_id, subscription_id, user_id, amount, payment_date, payment_method, status, transaction_id, currency, invoice_url)
    VALUES ((SELECT IFNULL(MAX(payment_id),0)+1 FROM payments), p_sub, p_user, p_amount, CURRENT_DATE, 'Card', 'Success', CONCAT('TXN', (SELECT IFNULL(MAX(payment_id),0)+1 FROM payments)), 'USD', NULL);
    UPDATE subscriptions SET is_active = TRUE, last_payment_date = CURRENT_DATE WHERE subscription_id = p_sub;
  COMMIT;
END$$

-- 95. SP: Move tracks from one playlist to another
CREATE PROCEDURE sp_move_playlist_tracks(IN p_from INT, IN p_to INT)
BEGIN
  UPDATE playlist_tracks SET playlist_id = p_to WHERE playlist_id = p_from;
  UPDATE playlists SET total_tracks = (SELECT COUNT(*) FROM playlist_tracks WHERE playlist_id = p_to) WHERE playlist_id = p_to;
END$$

DELIMITER ;

-- ================================
-- Section 11: Window Functions (5 queries)
-- RANK(), ROW_NUMBER(), LEAD(), LAG()
-- ================================

-- 96. Rank tracks globally by popularity
SELECT track_id, track_title, popularity_score, RANK() OVER (ORDER BY popularity_score DESC) AS pop_rank FROM tracks LIMIT 50;

-- 97. Row number within album showing top track per album as rn=1
SELECT track_id, album_id, track_title, ROW_NUMBER() OVER (PARTITION BY album_id ORDER BY popularity_score DESC) AS rn FROM tracks;

-- 98. Use LEAD to compare track plays trend in playlist_tracks (requires play_count ordering)
SELECT playlist_track_id, playlist_id, track_id, play_count, LEAD(play_count,1) OVER (PARTITION BY playlist_id ORDER BY play_count DESC) AS next_play_count FROM playlist_tracks LIMIT 200;

-- 99. Use LAG to see previous play_count per playlist track
SELECT playlist_track_id, playlist_id, track_id, play_count, LAG(play_count,1) OVER (PARTITION BY playlist_id ORDER BY play_count DESC) AS prev_play_count FROM playlist_tracks LIMIT 200;

-- 100. Dense rank artists by monthly_listeners
SELECT artist_id, stage_name, monthly_listeners, DENSE_RANK() OVER (ORDER BY monthly_listeners DESC) AS listener_dense_rank FROM artists LIMIT 50;