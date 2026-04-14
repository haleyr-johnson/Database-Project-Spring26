INSERT INTO Spring26_S008_T3_USER VALUES (233, 'zendaya13', 'zendaya13@gmail.com', DATE '1996-09-01', 'Other', 'Australia', DATE '2026-04-14', 'Free');

SELECT username
FROM Spring26_S008_T3_USER
WHERE membership_type = 'Premium' AND location = 'United States';

UPDATE Spring26_S008_T3_USER SET membership_type = 'Premium' WHERE User_ID = 233;

SELECT username
FROM Spring26_S008_T3_USER
WHERE membership_type = 'Premium' AND location = 'United States';

DELETE FROM Spring26_S008_T3_USER WHERE User_ID = 233;