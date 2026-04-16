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
    x.Title,x.Show_ID, y.Season_Number, 
    AVG(y.Rating) as RAvg,
    Count(*) as RCount
FROM Spring26_S008_T3_WATCH_LOG y
JOIN Spring26_S008_T3_TV_SHOW x
    ON x.Show_ID =y.Show_ID
GROUP BY CUBE (x.Show_ID, y.Season_Number, x.Title)
HAVING AVG(y.Rating) >=4 AND COUNT(*)>3
ORDER BY RAvg DESC;




-- Query 4:
-- What are the top 10 highest rated shows in the United States or the United Kingdom that did not begin airing until after 2010?
-- Joined the Shows and WatchLog tables based on Show_ID.
-- Grouped by shows whose country has "United" in the name and it starts after 2010. 
-- Fetched the top 10 rows

-- Expected output:
-- TITLE				                  COUNTRY					                START_YEAR  TOP_RATING
-- ------------------------------------  ----------------------------------------	----------  ----------
-- Banshee 			                  United States				                        2013	   3.675
-- The Americans			              United States				                    2013    3.66666667
-- Gravity Falls			              United States				                    2012	    3.5
-- Better Call Saul		              United States				                        2015    3.28333333
-- Shameless			                  United States				                    2011	    3.2
-- Rick and Morty			              United States				                    2013    3.13333333
-- Line of Duty			              United Kingdom				                    2012	    3.1
-- Person of Interest		              United States				                    2011	   2.85
-- Peaky Blinders			              United Kingdom				                2013	   2.3
-- Game of Thrones 		              United States				                        2011	   2.1

-- 10 rows selected.


SELECT s.Title, s.Country, s.Start_Year, AVG(w.Rating) as Top_Rating
FROM Spring26_S008_T3_TV_SHOW s, Spring26_S008_T3_WATCH_LOG w
WHERE s.Show_ID = w.Show_ID 
GROUP BY s.Title, s.Country, s.Start_Year
HAVING s.Country Like 'United%' AND s.Start_Year > 2010
ORDER BY Top_Rating DESC
FETCH FIRST 10 ROWS ONLY;



-- Query 5:
-- What are the ratings (in descending order) of shows that only air on only 1 platform?
-- Selected shows that only once on the platform relation and averaged out the ratings from watch log
-- Expected Output:

-- TITLE				                  PLATFORM					                EXCLUSIVE_RATING
-- ------------------------------------  ----------------------------------------	----------------
-- Battlestar Galactica		          Amazon Prime					                        4.45
-- Fringe				                  Hulu					                          4.43333333
-- The Americans			              Hulu					                          3.66666667
-- Dark Angel			                  Disney+						                         3.6
-- The Shield			                  Amazon Prime					                       3.525
-- Futurama			                  Disney+						                         3.5
-- Person of Interest		              Disney+						                        2.85
-- The X-Files			                  Disney+						                        2.15
-- The Sopranos			              HBO Max						                         1.1

-- 9 rows selected.



SELECT s.Title, p.Platform, AVG(w.Rating) as Exclusive_Rating
FROM Spring26_S008_T3_TV_SHOW s, Spring26_S008_T3_TV_SHOW_PLATFORM p, Spring26_S008_T3_WATCH_LOG w
WHERE s.Show_ID = w.Show_ID AND s.Show_ID = p.Show_ID AND s.Show_ID IN (
    SELECT show_ID 
    FROM Spring26_S008_T3_TV_SHOW_PLATFORM 
    GROUP BY Show_ID 
    HAVING Count(*) = 1
)
GROUP BY s.Title, p.Platform
ORDER BY Exclusive_Rating DESC;




-- Query 6:
-- What

-- Expected Output:
-- 
--  rows selected.

SELECT distinct c.User_ID
FROM Spring26_S008_T3_WATCH_LOG c
WHERE NOT EXISTS(

    Select DISTINCT d.Season_Number
    FROM Spring26_S008_T3_WATCH_LOG d
    WHERE d.Show_ID = c.Show_ID

    AND NOT EXISTS(
        SELECT 1
        FROM Spring26_S008_T3_WATCH_LOG e
        WHERE e.User_ID = c.User_ID AND e.Show_ID = d.Show_ID AND e.Season_Number=d.Season_Number
    )
);

