# Database-Project-Spring26
Database project for Database systems &amp; file structures. TV Show Tracking db.

## SQL Data Generation Script with Faker library

Python script to generates SQL `INSERT` statements for populating all database tables with realistic sample data.

### Setup

Install required dependency:

```bash
pip install faker

### Run

```bash
python generate_all.py > [outputfilename].sql

- for tvshows/seasons/episodes I used TVMaze's public api so that the data was from real tv shows, then I used faker for the extra attributes that arent always included in the api's data.
- I also limited the number of seasons to 3 per show, and 5 episodes per season, because otherwise the data set was wayyyy too huge.