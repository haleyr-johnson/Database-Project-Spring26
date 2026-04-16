-- added Zendaya13 to USER TABLE and updated her location from Australia to Japan

INSERT INTO Spring26_S008_T3_USER VALUES (233, 'zendaya13', 'zendaya13@gmail.com', DATE '1996-09-01', 'Other', 'Australia', DATE '2026-04-14', 'Free');

SELECT Username as Users_From_Australia
FROM Spring26_S008_T3_USER 
WHERE Location Like 'Australia';

UPDATE Spring26_S008_T3_USER SET Location = 'Japan' WHERE User_ID = 233;

SELECT Username as Users_From_Australia
FROM Spring26_S008_T3_USER 
WHERE Location Like 'Australia';

SELECT Username Users_From_Japan
FROM Spring26_S008_T3_USER 
WHERE Location Like 'Japan';

DELETE FROM Spring26_S008_T3_USER WHERE User_ID = 233;


-- updated Watchlist (ID = 2018) entry from Futurama to Peaky Blinders, so Futurama appears last in Query 1's results
UPDATE Spring26_S008_T3_WATCHLIST SET Show_ID = 269 WHERE Watchlist_ID = 2018;

-- update Banshee's location so it is not present in Query 4's results
UPDATE Spring26_S008_T3_TV_SHOW SET Country = 'Korea' WHERE Show_ID = 164;

-- update all of Battlestart Galactica's ratings to 0 so appears last in Query 5's results
UPDATE Spring26_S008_T3_WATCH_LOG SET Rating = 0 WHERE Show_ID = 166;
