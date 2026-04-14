# TV Show Tracking Database System

## Overview

This project implements a relational database system for tracking user interactions with television shows. The system allows users to log watched episodes, leave reviews, and interact with other users’ reviews through likes and comments.

Designed using an EER model and mapped to a relational schema.

---

## Database Design
[Phase 1 Document](./Phase%201/team3_phase1_FINAL_REVISED.docx)
[EER Diagram](./Phase%202/EER%20Diagram_FINAL_REVISED.pdf)
[Relational Schema](./Phase%203/Relational_Schema-FINAL.pdf)

### Entity Structure

* **TV_SHOW**: Stores information about television shows
* **SEASON** (weak entity): Identified by *(Show_ID, Season_Number)*
* **EPISODE** (weak entity): Identified by *(Show_ID, Season_Number, Episode_Number)*
* **USER**: Stores user account information
* **WATCH_LOG**: Tracks episodes watched by users
* **REVIEW** (weak entity): Identified by *(Log_ID, Review_ID)*
* **REVIEW_INTERACTION** (weak entity): Identified by *(Review_ID, Interaction_ID)*
* **LIKE** and **COMMENT**: Subtypes of review interactions

---

### Normalization

All relations in the final schema are normalized to **Boyce-Codd Normal Form (BCNF)**.

---

## Scripts Included

### 1. `projectDBcreate.sql`

* Contains all `CREATE TABLE` statements

---

### 2. `projectDBinsert.sql`

* Populates the database with realistic data
* Data generated using Python and the Faker library
* Includes ~40–50 rows per table

---

### 3. `projectDBupdate.sql`

* Performs updates, inserts, and deletions

---

### 4. `projectDBdrop.sql`

* Drops all tables in reverse dependency order

---

### 5. `projectDBqueries.sql`

* Contains analytical SQL queries to answer business goals:

---

## How to Run

1. Run the create script:

```sql
@projectDBcreate.sql
```

2. Populate the database:

```sql
@projectDBinsert.sql
```

3. Execute queries:

```sql
@projectDBqueries.sql
```

4. Test updates:

```sql
@projectDBupdate.sql
```

5. Reset database if needed:

```sql
@projectDBdrop.sql
```

---

## SQL Data Generation Script with Faker library

Python script to generates SQL `INSERT` statements for populating all database tables with realistic sample data.

### Setup

Install required dependency:

```bash
pip install faker
```

### Run

```bash
python generate_all.py > [outputfilename].sql
```

- for tvshows/seasons/episodes I used TVMaze's public api so that the data was from real tv shows, then I used faker for the extra attributes that arent always included in the api's data.
- I also limited the number of seasons to 3 per show, and 5 episodes per season, because otherwise the data set was wayyyy too huge.