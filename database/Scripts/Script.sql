CREATE TABLE USERS(
	ID INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
	USERNAME TEXT(256) NOT NULL UNIQUE,
	EMAIL TEXT(256) NOT NULL UNIQUE,
	HASHED_PASS TEXT NOT NULL


)