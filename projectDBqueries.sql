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
FROM Spring26_S008_T3_TV_SHOW tv
JOIN Spring26_S008_T3_WATCHLIST w ON tv.Show_ID = w.Show_ID
WHERE tv.Status IN ('Upcoming', 'Ongoing')
GROUP BY tv.Show_ID, tv.Title, tv.Status
HAVING COUNT(w.Watchlist_ID) > (
    SELECT AVG(show_watchlist_count)
    FROM (
        SELECT COUNT(*) AS show_watchlist_count
        FROM Spring26_S008_T3_WATCHLIST
        GROUP BY Show_ID
    )
)
ORDER BY Watchlist_Appearances DESC;


-- Query 2:
-- Which TV shows and seasons generate the highest levels of user engagement?
-- Only include shows or seasons that have at least 1 review or interaction.
-- Measured by the sum of the number of distinct reviews per episode and number of interactions (likes, comments) on those reviews.

-- Results are grouped by show and season using ROLLUP to include:
--   - season-level totals
--   - show-level totals
--   - grand total across all shows

-- Expected Output:

-- SHOW_ID  SEASON_NUMBER  TOTAL_REVIEWS  TOTAL_INTERACTIONS  TOTAL_ENGAGEMENT
-- -------  -------------  -------------  ------------------  ----------------
--     2           3               1               0                 1   -- ascending order
--     2                           1               0                 1
--   ...         ...             ...              ...              ...
--   618           1               1               1                 2   
--   618           2               3               7                10   -- season total
--   618           3               2               1                 3
--   618                           6               9                15   -- show total
--   ...         ...              ...             ...              ...
--                                50              50               100   -- grand total
-- 65 rows selected.

SELECT
    ep.Show_ID, 
    ep.Season_Number,
    COUNT(DISTINCT r.Review_ID) AS Total_Reviews,
    COUNT(DISTINCT i.Interaction_ID) AS Total_Interactions,
    (COUNT(DISTINCT r.Review_ID) + COUNT(DISTINCT i.Interaction_ID)) AS Total_Engagement
FROM Spring26_S008_T3_EPISODE ep
JOIN Spring26_S008_T3_WATCH_LOG w ON ep.Show_ID = w.Show_ID
    AND ep.Season_Number = w.Season_Number
    AND ep.Episode_Number = w.Episode_Number
JOIN Spring26_S008_T3_REVIEW r ON w.Log_ID = r.Log_ID
LEFT JOIN Spring26_S008_T3_REVIEW_INTERACTION i ON r.Review_ID = i.Review_ID -- I used LEFT JOIN to make sure as long as it has one type of engagement it counts
GROUP BY ROLLUP(ep.Show_ID, ep.Season_Number)
ORDER BY Show_ID ASC, Season_Number ASC;


-- Query 3:
-- Which TV SHOWS and SEASONS have the highest average user ratings across shows and seasons,
-- including subtotals and aggregates.
-- Measured by the average ratings provided by the watch log entries.
-- Results are grouped by show and season along with CUBE
--
-- Expected Output:
-- 
-- TITLE                                    SHOW_ID  SEASON_NUMBER  AVG_RATING  RATING_COUNT
-- ------------------------------------  ----------  -------------  ----------  ------------
-- Battlestar Galactica                         166              3        4.45             2
--                                              166              3        4.45             2
-- Battlestar Galactica                         166                       4.45             2
--                                              166                       4.45             2
--                                              179              2        4.45             2
-- Battlestar Galactica                                          3        4.45             2
-- Battlestar Galactica                                                   4.45             2
-- The Wire                                                      2        4.45             2
-- The Wire                                     179              2        4.45             2
-- Fringe                                       158              1        4.43             3
-- Fringe                                       158                       4.43             3
--                                              158                       4.43             3
-- Fringe                                                        1        4.43             3
-- Fringe                                                                 4.43             3
--                                              158              1        4.43             3
-- The Shield                                                    2        4.25             2
--                                              663              2        4.25             2
-- The Shield                                   663              2        4.25             2
-- 
-- 18 rows selected.

SELECT
    x.Title, x.Show_ID, y.Season_Number, 
    ROUND(AVG(y.Rating), 2) as Avg_Rating,
    Count(*) as Rating_Count
FROM Spring26_S008_T3_WATCH_LOG y
JOIN Spring26_S008_T3_TV_SHOW x
    ON x.Show_ID = y.Show_ID
GROUP BY CUBE (x.Show_ID, y.Season_Number, x.Title)
HAVING AVG(y.Rating) >= 4 AND COUNT(*) > 1
ORDER BY Avg_Rating DESC;


-- Query 4:
-- What are the top 10 highest rated shows from countries that start with "United" (United States or the United Kingdom in our sample data), that did not begin airing until after 2010?
-- Joined the Shows and Watch_Log tables based on Show_ID.
-- Grouped by shows whose country has "United" in the name and it starts after 2010. 
-- Fetched the top 10 rows

-- Expected output:
--
-- TITLE                                 COUNTRY          START_YEAR  AVG_TOP_RATING
-- ------------------------------------  ---------------  ----------  --------------
-- Banshee                               United States          2013            3.68
-- The Americans                         United States          2013            3.67
-- Gravity Falls                         United States          2012             3.5
-- Better Call Saul                      United States          2015            3.28
-- Shameless                             United States          2011             3.2
-- Rick and Morty                        United States          2013            3.13
-- Line of Duty                          United Kingdom         2012             3.1
-- Person of Interest                    United States          2011            2.85
-- Peaky Blinders                        United Kingdom         2013             2.3
-- Game of Thrones                       United States          2011             2.1
--
-- 10 rows selected.

COLUMN TITLE FORMAT A36
COLUMN COUNTRY FORMAT A15

SELECT s.Title, s.Country, s.Start_Year,
       ROUND(AVG(w.Rating), 2) as Avg_Top_Rating
FROM Spring26_S008_T3_TV_SHOW s
JOIN Spring26_S008_T3_WATCH_LOG w ON s.Show_ID = w.Show_ID
WHERE s.Country LIKE 'United%' AND s.Start_Year > 2010 AND w.Rating IS NOT NULL
GROUP BY s.Title, s.Country, s.Start_Year
ORDER BY Avg_Top_Rating DESC
FETCH FIRST 10 ROWS ONLY;


-- Query 5:
-- What are the ratings (in descending order) of shows that only air on only 1 platform?
-- Selected shows that only once on the platform relation and averaged out the ratings from watch log
-- Expected Output:

-- TITLE                                 PLATFORM         EXCLUSIVE_RATING
-- ------------------------------------  ---------------  ----------------
-- Battlestar Galactica                  Amazon Prime                 4.45
-- Fringe                                Hulu                         4.43
-- The Americans                         Hulu                         3.67
-- Dark Angel                            Disney+                       3.6
-- The Shield                            Amazon Prime                 3.53
-- Futurama                              Disney+                       3.5
-- Person of Interest                    Disney+                      2.85
-- The X-Files                           Disney+                      2.15
-- The Sopranos                          HBO Max                       1.1
-- 
-- 9 rows selected.

COLUMN TITLE FORMAT A36
COLUMN PLATFORM FORMAT A15

SELECT s.Title, p.Platform, ROUND(AVG(w.Rating), 2) as Exclusive_Rating
FROM Spring26_S008_T3_TV_SHOW s, Spring26_S008_T3_TV_SHOW_PLATFORM p, Spring26_S008_T3_WATCH_LOG w
WHERE s.Show_ID = w.Show_ID
    AND s.Show_ID = p.Show_ID
    AND s.Show_ID IN (
    SELECT show_ID 
    FROM Spring26_S008_T3_TV_SHOW_PLATFORM 
    GROUP BY Show_ID 
    HAVING Count(p.Platform) = 1
    )
GROUP BY s.Title, p.Platform
ORDER BY Exclusive_Rating DESC;


-- Query 6:
-- Which users have watched every episode of at least one season of a TV show? Output the user_id and username.
-- Uses division by identifying users for whom there does not exist and episode in the Episode table (for a specific season) that they have not logged in their Watch_Log.
-- 
-- Expected Output:
-- 

SELECT distinct w.User_ID
FROM Spring26_S008_T3_WATCH_LOG w
WHERE NOT EXISTS(
    SELECT 1
    FROM Spring26_S008_T3_EPISODE e
    WHERE NOT EXISTS (
        SELECT 1
        FROM Spring26_S008_T3_WATCH_LOG w2
        WHERE w2.User_ID = w.User_ID
            AND w2.Show_ID = e.Show_ID
            AND w2.Season_Number = e.Season_Number
            AND w2.Episode_Number = e.Episode_Number
    )
);

-- TESTINGG
SELECT DISTINCT u.User_ID, u.Username
FROM Spring26_S008_T3_USER u
WHERE EXISTS (
    SELECT 1
    FROM Spring26_S008_T3_EPISODE e
    WHERE NOT EXISTS (
        SELECT 1
        FROM Spring26_S008_T3_EPISODE e2
        WHERE e2.Show_ID = e.Show_ID
          AND e2.Season_Number = e.Season_Number
          AND NOT EXISTS (
              SELECT 1
              FROM Spring26_S008_T3_WATCH_LOG w
              WHERE w.User_ID = u.User_ID
                AND w.Show_ID = e2.Show_ID
                AND w.Season_Number = e2.Season_Number
                AND w.Episode_Number = e2.Episode_Number
          )
    )
);

