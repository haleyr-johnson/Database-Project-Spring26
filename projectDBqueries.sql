-- Query 1:
-- Find the show_id and title of upcoming or ongoing TV shows that
-- are added to watchlists more than the platform average across all shows.
-- Also output the watchlist appearance count.
-- This identifies "most anticipated" shows.

-- Expected Output:
--
--
--
--

SELECT tv.Show_ID, tv.Title, tv.Status, COUNT(w.Watchlist_ID) AS Watchlist_Appearances
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
ORDER BY watchlist count DESC;
FETCH FIRST 5 ROWS ONLY;

-- Query 2:
-- Which TV shows and seasons generate the highest levels of user engagement?
-- Measured by the number of reviews and interactions (likes, comments).
-- Uses ROLLUP to give subtotals for each show and grand total.

-- Expected Output:
--
--
--
--

SELECT
    ep.Show_ID, 
    ep.Season_Number
    COUNT(DISTINCT r.Review_ID) AS Total_Reviews,
    COUNT(i.Interaction_ID) AS Total_Interactions,
    (COUNT(DISTINCT r.Review_ID) + COUNT(i.Interaction_ID)) AS Total_Engagement
FROM Spring26_S008_T3_EPISODE ep
JOIN Spring26_S008_T3_WATCH_LOG w ON ep.Show_ID = w.Show_ID
    AND ep.Season_Number = w.Season_Number
    AND ep.Episode_Number = w.Episode_Number
JOIN Spring26_S008_T3_REVIEW r ON w.Log_ID = r.Log_ID
LEFT JOIN Spring26_S008_T3_REVIEW_INTERACTION i ON r.Review_ID = i.Review_ID -- I used LEFT JOIN to make sure as long as it has one type of engagement it counts
GROUP BY ROLLUP(ep.Show_ID, ep.Season_Number)
ORDER BY Total_Engagement DESC;
