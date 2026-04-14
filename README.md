# Database-Project-Spring26
Database project for Database systems &amp; file structures. TV Show Tracking db.

**to use faker to create dummy inserts:**
create the script to insert for specific relation. Then

**run:** python generate_inserts.py > [filename.sql]

DO NOT direct it to projectDBinsert.sql, instead we can use separate files and manually combine later. This is to avoid overwritting, or dupes, etc.

ALSO, must double check that the foreign keys are valid (user id in USER actually exists/maps to a user id in REVIEW, etc.)

for tvshows/seasons/episodes I used TVMaze's public api so that the data was from real tv shows, then i used faker for the extra attributes like platform or language which arent always included in the api's data. I also limited the number of seasons to 3 per show, and 5 episodes per season, because otherwise the data set was wayyyy too huge.