Create Table Spring26_S008_T3_USER (
    User_ID NUMBER PRIMARY KEY, Username VARCHAR2(200) UNIQUE, Email VARCHAR2(200), DOB DATE, Gender VARCHAR2(200), Location VARCHAR2(200), Creation_Date DATE, Membership VARCHAR2(200)
);

Create Table Spring26_S008_T3_TV_SHOW (
    Show_ID NUMBER PRIMARY KEY, Title VARCHAR2(200), Country VARCHAR2(200), Start_Year NUMBER, Status VARCHAR2(200)
);

Create Table Spring26_S008_T3_TV_SHOW_GENRE (
    Show_ID NUMBER, Genre VARCHAR2(200), 
    PRIMARY KEY (Show_ID, Genre), 
    Foreign KEY (Show_ID) REFERENCES Spring26_S008_T3_TV_SHOW (Show_ID)
);

Create Table Spring26_S008_T3_TV_SHOW_LANGUAGE (
    Show_ID NUMBER, Language VARCHAR2(200), 
    PRIMARY KEY (Show_ID, Language), 
    Foreign KEY (Show_ID) REFERENCES Spring26_S008_T3_TV_SHOW(Show_ID)
);

Create Table Spring26_S008_T3_TV_SHOW_PLATFORM (
    Show_ID NUMBER, Platform VARCHAR2(200), 
    PRIMARY KEY (Show_ID, Platform),
    Foreign KEY (Show_ID) REFERENCES Spring26_S008_T3_TV_SHOW (Show_ID)

);

Create Table Spring26_S008_T3_SEASON (
    Show_ID NUMBER, Season_Number NUMBER, Release_Year NUMBER,
    PRIMARY KEY (Show_ID, Season_Number),
    Foreign KEY(Show_ID) REFERENCES Spring26_S008_T3_TV_SHOW(Show_ID)
);

Create Table Spring26_S008_T3_EPISODE (
    Show_ID  NUMBER, Season_Number NUMBER, Episode_Number NUMBER, Title VARCHAR2(200), Runtime NUMBER, Air_Date DATE,
    PRIMARY KEY (Show_ID, Season_Number, Episode_Number),
    Foreign KEY (Show_ID, Season_Number) REFERENCES Spring26_S008_T3_SEASON(Show_ID,Season_Number)
);

Create Table Spring26_S008_T3_WATCHLIST (
    Watchlist_ID NUMBER PRIMARY KEY, User_ID NUMBER, Show_ID NUMBER, Added_Date DATE, 
    Foreign KEY (User_ID) REFERENCES Spring26_S008_T3_USER(User_ID),
    Foreign KEY(Show_ID) REFERENCES Spring26_S008_T3_TV_SHOW(Show_ID)
);

Create Table Spring26_S008_T3_FOLLOWS(
    Follower_ID NUMBER, Following_ID NUMBER, 
    PRIMARY KEY (Follower_ID, Following_ID),
    Foreign KEY (Follower_ID) REFERENCES Spring26_S008_T3_USER(User_ID),
    Foreign KEY (Following_ID) REFERENCES Spring26_S008_T3_USER(User_ID)
);

Create Table Spring26_S008_T3_WATCH_LOG (
    Log_ID NUMBER PRIMARY KEY, User_ID NUMBER, Show_ID NUMBER, Season_Number NUMBER, Episode_Number NUMBER, Watch_Date DATE, Watch_Type VARCHAR2(200), Rating NUMBER,
    Foreign KEY (User_ID) REFERENCES Spring26_S008_T3_USER(User_ID),
    Foreign KEY (Show_ID, Season_Number, Episode_Number) REFERENCES Spring26_S008_T3_EPISODE(Show_ID, Season_Number, Episode_Number)
);

Create Table Spring26_S008_T3_REVIEW (
    Log_ID NUMBER, PRIMARY KEY Review_ID NUMBER, User_ID NUMBER, Review_Text VARCHAR2(200), Review_DATE DATE,
    Foreign KEY (Log_ID) REFERENCES Spring26_S008_T3_WATCH_LOG(Log_ID),
    Foreign KEY (User_ID) REFERENCES Spring26_S008_T3_USER(User_ID)
);

Create Table Spring26_S008_T3_REVIEW_INTERACTION (
    Review_ID NUMBER, Interaction_ID NUMBER, User_ID NUMBER, Interaction_Date DATE, 
    PRIMARY KEY (Review_ID, Interaction_ID), 
    Foreign KEY (Review_ID) REFERENCES Spring26_S008_T3_REVIEW (Review_ID),
    Foreign KEY (User_ID ) REFERENCES Spring26_S008_T3_USER(User_ID)
);

Create Table Spring26_S008_T3_LIKE (
    Review_ID NUMBER, Interaction_ID NUMBER, 
    PRIMARY KEY (Review_ID, Interaction_ID),
    Foreign KEY (Review_ID, Interaction_ID) REFERENCES Spring26_S008_T3_REVIEW_INTERACTION(Review_ID,Interaction_ID)
);

Create Table Spring26_S008_T3_COMMENT (
    Review_ID NUMBER, Interaction_ID NUMBER, Comment_Text VARCHAR2(200), 
    PRIMARY KEY (Review_ID, Interaction_ID),
    Foreign KEY (Review_ID, Interaction_ID) REFERENCES Spring26_S008_T3_REVIEW_INTERACTION (Review_ID, Interaction_ID)
);