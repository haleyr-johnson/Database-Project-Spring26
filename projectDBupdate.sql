-- added Zendaya13 to USER TABLE
INSERT INTO Spring26_S008_T3_USER VALUES (233, 'zendaya13', 'zendaya13@gmail.com', DATE '1996-09-01', 'Other', 'Australia', DATE '2026-04-14', 'Free');

-- deleted william11 from USER TABLE
DELETE FROM Spring26_S008_T3_USER WHERE User_ID = 1000;

-- updated nlane's country to Canada from United Kingdom on USER TABLE
UPDATE Spring26_S008_T3_USER SET Country = 'Canada' WHERE User_ID = 1001;



INSERT INTO Spring26_S008_T3_TV_SHOW VALUES (999, 'Greys Anatomy', 'United States', 2005, 'Completed');
INSERT INTO Spring26_S008_T3_TV_SHOW_GENRE VALUES (999, 'Drama');
INSERT INTO Spring26_S008_T3_TV_SHOW_LANGUAGE VALUES (169, 'English');
