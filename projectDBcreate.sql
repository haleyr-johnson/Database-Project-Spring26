Create Table Spring26_S008_T3_USER (
    User_ID NUMBER PRIMARY KEY,
    Username VARCHAR2(200) NOT NULL UNIQUE,
    Email VARCHAR2(200) NOT NULL,
    DOB DATE,
    Gender VARCHAR2(20),
    Location VARCHAR2(100),
    Account_Creation_Date DATE NOT NULL,
    Membership_Type VARCHAR2(200)
);

Create Table Spring26_S008_T3_TV_SHOW (
    Show_ID NUMBER PRIMARY KEY,
    Title VARCHAR2(200) NOT NULL,
    Country VARCHAR2(200),
    Start_Year NUMBER,
    Status VARCHAR2(200)
);

Create Table Spring26_S008_T3_TV_SHOW_GENRE (
    Show_ID NUMBER NOT NULL,
    Genre VARCHAR2(200), 
    PRIMARY KEY (Show_ID, Genre), 
    Foreign KEY (Show_ID) REFERENCES Spring26_S008_T3_TV_SHOW (Show_ID)
);

Create Table Spring26_S008_T3_TV_SHOW_LANGUAGE (
    Show_ID NUMBER NOT NULL,
    Language VARCHAR2(50), 
    PRIMARY KEY (Show_ID, Language), 
    Foreign KEY (Show_ID) REFERENCES Spring26_S008_T3_TV_SHOW(Show_ID)
);

Create Table Spring26_S008_T3_TV_SHOW_PLATFORM (
    Show_ID NUMBER NOT NULL,
    Platform VARCHAR2(200), 
    PRIMARY KEY (Show_ID, Platform),
    Foreign KEY (Show_ID) REFERENCES Spring26_S008_T3_TV_SHOW (Show_ID)
);

Create Table Spring26_S008_T3_SEASON (
    Show_ID NUMBER NOT NULL,
    Season_Number NUMBER NOT NULL,
    Release_Year NUMBER,
    PRIMARY KEY (Show_ID, Season_Number),
    Foreign KEY(Show_ID) REFERENCES Spring26_S008_T3_TV_SHOW(Show_ID)
);

Create Table Spring26_S008_T3_EPISODE (
    Show_ID  NUMBER NOT NULL,
    Season_Number NUMBER NOT NULL,
    Episode_Number NUMBER NOT NULL,
    Title VARCHAR2(200),
    Runtime NUMBER,
    Air_Date DATE,
    PRIMARY KEY (Show_ID, Season_Number, Episode_Number),
    Foreign KEY (Show_ID, Season_Number) REFERENCES Spring26_S008_T3_SEASON(Show_ID, Season_Number)
);

Create Table Spring26_S008_T3_WATCHLIST (
    Watchlist_ID NUMBER PRIMARY KEY,
    User_ID NUMBER NOT NULL,
    Show_ID NUMBER NOT NULL,
    Added_Date DATE NOT NULL, 
    Foreign KEY (User_ID) REFERENCES Spring26_S008_T3_USER(User_ID),
    Foreign KEY(Show_ID) REFERENCES Spring26_S008_T3_TV_SHOW(Show_ID)
);

Create Table Spring26_S008_T3_FOLLOWS (
    Follower_ID NUMBER NOT NULL,
    Following_ID NUMBER NOT NULL,
    PRIMARY KEY (Follower_ID, Following_ID),
    Foreign KEY (Follower_ID) REFERENCES Spring26_S008_T3_USER(User_ID),
    Foreign KEY (Following_ID) REFERENCES Spring26_S008_T3_USER(User_ID)
);

Create Table Spring26_S008_T3_WATCH_LOG (
    Log_ID NUMBER PRIMARY KEY,
    User_ID NUMBER NOT NULL,
    Show_ID NUMBER NOT NULL,
    Season_Number NUMBER NOT NULL,
    Episode_Number NUMBER NOT NULL,
    Watch_Date DATE,
    Watch_Type VARCHAR2(20),
    Rating NUMBER,
    Foreign KEY (User_ID) REFERENCES Spring26_S008_T3_USER(User_ID),
    Foreign KEY (Show_ID, Season_Number, Episode_Number) REFERENCES Spring26_S008_T3_EPISODE(Show_ID, Season_Number, Episode_Number)
);

Create Table Spring26_S008_T3_REVIEW (
    Log_ID NUMBER NOT NULL,
    Review_ID NUMBER NOT NULL UNIQUE,
    User_ID NUMBER NOT NULL,
    Review_Text VARCHAR2(1000),
    Date_Posted DATE,
    PRIMARY KEY (Log_ID, Review_ID),
    Foreign KEY (Log_ID) REFERENCES Spring26_S008_T3_WATCH_LOG(Log_ID),
    Foreign KEY (User_ID) REFERENCES Spring26_S008_T3_USER(User_ID)
);

Create Table Spring26_S008_T3_REVIEW_INTERACTION (
    Review_ID NUMBER NOT NULL,
    Interaction_ID NUMBER NOT NULL,
    User_ID NUMBER NOT NULL,
    Interaction_Date DATE, 
    PRIMARY KEY (Review_ID, Interaction_ID),
    Foreign KEY (Review_ID) REFERENCES Spring26_S008_T3_REVIEW (Review_ID),
    Foreign KEY (User_ID ) REFERENCES Spring26_S008_T3_USER(User_ID)
);

Create Table Spring26_S008_T3_LIKE (
    Review_ID NUMBER NOT NULL,
    Interaction_ID NUMBER NOT NULL, 
    PRIMARY KEY (Review_ID, Interaction_ID),
    Foreign KEY (Review_ID, Interaction_ID) REFERENCES Spring26_S008_T3_REVIEW_INTERACTION(Review_ID,Interaction_ID)
);

Create Table Spring26_S008_T3_COMMENT (
    Review_ID NUMBER NOT NULL,
    Interaction_ID NUMBER NOT NULL,
    Comment_Text VARCHAR2(1000), 
    PRIMARY KEY (Review_ID, Interaction_ID),
    Foreign KEY (Review_ID, Interaction_ID) REFERENCES Spring26_S008_T3_REVIEW_INTERACTION (Review_ID, Interaction_ID)
);

-- ALTER TABLES
-- Derived attribute Age
ALTER TABLE Spring26_S008_T3_USER 
ADD (Age AS (FLOOR(MONTHS_BETWEEN(SYSDATE, DOB) / 12)));
CREATE OR REPLACE VIEW Spring26_S008_T3_USER_WITH_AGE AS
SELECT *, 
       FLOOR(MONTHS_BETWEEN(SYSDATE, DOB) / 12) AS Age
FROM Spring26_S008_T3_USER;

-- Ensure Rating is between 1.0 and 5.0
ALTER TABLE Spring26_S008_T3_WATCH_LOG 
ADD CONSTRAINT chk_rating CHECK (Rating >= 1.0 AND Rating <= 5.0);

-- Ensure valid show status type
ALTER TABLE Spring26_S008_T3_TV_SHOW 
ADD CONSTRAINT chk_status CHECK (Status IN ('Ongoing', 'Completed', 'Upcoming', 'Canceled'));

-- TRIGGERS
-- Ensure Account_Creation_Date isn't in the future
CREATE OR REPLACE TRIGGER trg_check_creation_date
BEFORE INSERT OR UPDATE ON Spring26_S008_T3_USER
FOR EACH ROW
BEGIN
    IF :NEW.Account_Creation_Date > SYSDATE THEN
        RAISE_APPLICATION_ERROR(-20002, 'Account creation date cannot be in the future.');
    END IF;
END;
/


-- Prevents a user from following themselves
CREATE OR REPLACE TRIGGER trg_prevent_self_follow
BEFORE INSERT OR UPDATE ON Spring26_S008_T3_FOLLOWS
FOR EACH ROW
BEGIN
    IF :NEW.Follower_ID = :NEW.Following_ID THEN
        RAISE_APPLICATION_ERROR(-20001, 'Logic Error: A user cannot follow themselves.');
    END IF;
END;
/