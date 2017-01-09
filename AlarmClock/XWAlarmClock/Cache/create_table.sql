
CREATE TABLE IF NOT EXISTS XWAlarm (
alarmId INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL UNIQUE,
weeks varchar(255,0),
bells varchar(255,0),
time double,
isOpen integer
);
