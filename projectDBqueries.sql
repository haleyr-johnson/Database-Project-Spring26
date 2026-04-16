-- Have MAVID.Table_Name for testing purposes, bc u need that for oracle to locate ur tables in omega.

-- Query 1:
-- Find the show_id and title of upcoming or ongoing TV shows that
-- are added to watchlists more than the platform average across all shows.
-- Also output the watchlist appearance count.
-- This identifies "most anticipated" shows.

-- Expected Output:

--    SHOW_ID  TITLE                                 STATUS                WATCHLIST_APPEARANCES
-- ----------  ------------------------------------  --------------------  ---------------------
--       8  Wife of a 21st Century Grand Prince   Upcoming                                  6
--      32  Fargo                                 Upcoming                                  3
--     538  Futurama                              Ongoing                                   3
--     269  Peaky Blinders                        Ongoing                                   2
--       7  Sold Out On You                       Upcoming                                  2

SET LINESIZE 200
SET PAGESIZE 200
SET COLSEP '  '

COLUMN TITLE FORMAT A36
COLUMN STATUS FORMAT A20

SELECT
    tv.Show_ID,
        tv.Title,
            tv.Status,
                COUNT(w.Watchlist_ID) AS Watchlist_Appearances
                FROM hxj3946.Spring26_S008_T3_TV_SHOW tv
                JOIN hxj3946.Spring26_S008_T3_WATCHLIST w ON tv.Show_ID = w.Show_ID
                WHERE tv.Status IN ('Upcoming', 'Ongoing')
                GROUP BY tv.Show_ID, tv.Title, tv.Status
                HAVING COUNT(w.Watchlist_ID) > (
                    SELECT AVG(show_watchlist_count)
                        FROM (
                                SELECT COUNT(*) AS show_watchlist_count
                                        FROM hxj3946.Spring26_S008_T3_WATCHLIST
                                                GROUP BY Show_ID
                                                    )
                                                    )
                                                    ORDER BY Watchlist_Appearances DESC;

-- Query 2:
-- Which TV shows and seasons generate the highest levels of user engagement?
-- Measured by the sum of the number of distinct reviews per episode and number of interactions (likes, comments) on those reviews.
-- Results are grouped by show and season using ROLLUP to include:
--   - season-level totals
--   - show-level totals
--   - grand total across all shows

-- Expected Output:

-- SHOW_ID  SEASON_NUMBER  TOTAL_REVIEWS  TOTAL_INTERACTIONS  TOTAL_ENGAGEMENT
-- -------  -------------  -------------  ------------------  ----------------
--   618           3               2               1                 3   -- season total
--   618           2               3               7                10
--   618           1               1               1                 2
--   618                           6               6                15   -- show total
--   ...         ...              ...             ...              ...
--                                50              50               100   -- grand total
-- 65 rows selected.

SELECT
    ep.Show_ID, 
    ep.Season_Number,
    COUNT(DISTINCT r.Review_ID) AS Total_Reviews,
    COUNT(DISTINCT i.Interaction_ID) AS Total_Interactions,
    (COUNT(DISTINCT r.Review_ID) + COUNT(DISTINCT i.Interaction_ID)) AS Total_Engagement
FROM hxj3946.Spring26_S008_T3_EPISODE ep
JOIN hxj3946.Spring26_S008_T3_WATCH_LOG w ON ep.Show_ID = w.Show_ID
    AND ep.Season_Number = w.Season_Number
    AND ep.Episode_Number = w.Episode_Number
JOIN hxj3946.Spring26_S008_T3_REVIEW r ON w.Log_ID = r.Log_ID
LEFT JOIN hxj3946.Spring26_S008_T3_REVIEW_INTERACTION i ON r.Review_ID = i.Review_ID -- I used LEFT JOIN to make sure as long as it has one type of engagement it counts
GROUP BY ROLLUP(ep.Show_ID, ep.Season_Number)
ORDER BY Show_ID, Season_Number DESC;


-- Query 3:
-- What TV SHOWS and SEASONS have the highest average ratings across shows and seasons with subtotals.
-- Measured by the average ratings are provided by the watch logs.
-- Results are grouped by show and season along with CUBE

-- Expected Output:
-- 
--  rows selected.
SELECT
    x.Show_ID, x.Season_Number, 
    AVG(x.Rating) RAvg
FROM Spring26_S008_T3_WATCH_LOG x
GROUP BY CUBE (x.Show_ID, x.Season_Number)
ORDER BY x.Show_ID, x.Season_Number

