-- FitHub: the running example from the IFB105 Exam Study Guide.
-- Run the whole script in MySQL Workbench, then try the queries at the bottom.

DROP DATABASE IF EXISTS fithub;
CREATE DATABASE fithub;
USE fithub;

CREATE TABLE Member (
  memberID    VARCHAR(5)   PRIMARY KEY,
  memberName  VARCHAR(50)  NOT NULL,
  phoneNo     VARCHAR(15),                    -- [optional] → NULL allowed
  email       VARCHAR(80)  NOT NULL UNIQUE    -- underlined in RMap → UNIQUE
);

CREATE TABLE Trainer (
  trainerID   VARCHAR(5)   PRIMARY KEY,
  trainerName VARCHAR(50)  NOT NULL,
  licenceNr   VARCHAR(10)  NOT NULL UNIQUE
);

CREATE TABLE Class (
  classCode   VARCHAR(6)   PRIMARY KEY,
  className   VARCHAR(50)  NOT NULL,
  trainerID   VARCHAR(5)   NOT NULL,
  roomNr      INT          NOT NULL,
  FOREIGN KEY (trainerID) REFERENCES Trainer(trainerID)
);

CREATE TABLE Booking (
  memberID    VARCHAR(5)   NOT NULL,
  classCode   VARCHAR(6)   NOT NULL,
  bookedOn    DATE         NOT NULL,
  PRIMARY KEY (memberID, classCode),
  FOREIGN KEY (memberID)  REFERENCES Member(memberID),
  FOREIGN KEY (classCode) REFERENCES Class(classCode)
);

CREATE TABLE Speaks (
  trainerID    VARCHAR(5)  NOT NULL,
  languageName VARCHAR(30) NOT NULL,
  PRIMARY KEY (trainerID, languageName),
  FOREIGN KEY (trainerID) REFERENCES Trainer(trainerID)
);

INSERT INTO Member VALUES
  ('M01', 'Ava Tran',  '0412000111', 'ava@mail.com'),
  ('M02', 'Ben Cole',  NULL,         'ben@mail.com'),
  ('M03', 'Cara Diaz', '0499222333', 'cara@mail.com'),
  ('M04', 'Dan Ho',    NULL,         'dan@mail.com');
INSERT INTO Trainer VALUES ('T3', 'Kim Ng', 'L-88'), ('T7', 'Sam Lee', 'L-12');
INSERT INTO Class VALUES ('YOG1', 'Yoga Flow', 'T7', 2), ('HIT2', 'HIIT Blast', 'T3', 1), ('SPN4', 'Spin Max', 'T7', 3);
INSERT INTO Booking VALUES
  ('M01', 'YOG1', '2026-03-03'), ('M01', 'HIT2', '2026-03-04'), ('M02', 'HIT2', '2026-03-03'),
  ('M03', 'YOG1', '2026-03-05'), ('M03', 'SPN4', '2026-03-05');
INSERT INTO Speaks VALUES ('T3', 'English'), ('T3', 'Korean'), ('T7', 'English');

-- ---------------------------------------------------------------- queries from chapter 4 (04-sql.md)
-- Classes with at least 2 bookings
SELECT classCode, COUNT(*) AS bookings FROM Booking GROUP BY classCode HAVING COUNT(*) >= 2;

-- INNER vs LEFT JOIN
SELECT m.memberName, b.classCode FROM Member m INNER JOIN Booking b ON m.memberID = b.memberID;
SELECT m.memberName, b.classCode FROM Member m LEFT JOIN Booking b ON m.memberID = b.memberID;

-- Members who have never booked
SELECT m.memberName FROM Member m LEFT JOIN Booking b ON m.memberID = b.memberID WHERE b.classCode IS NULL;

-- Nested IN: members booked into a class run by T7
SELECT memberName FROM Member
WHERE memberID IN (SELECT memberID FROM Booking
                   WHERE classCode IN (SELECT classCode FROM Class WHERE trainerID = 'T7'));

-- Bookings per trainer, busiest first
SELECT t.trainerName, COUNT(*) AS bookings
FROM Trainer t JOIN Class c ON c.trainerID = t.trainerID JOIN Booking b ON b.classCode = c.classCode
GROUP BY t.trainerID, t.trainerName ORDER BY bookings DESC;

-- EXCEPT (MySQL 8.0.31+)
SELECT memberID FROM Member EXCEPT SELECT memberID FROM Booking;

-- COUNT(*) vs COUNT(column)
SELECT COUNT(*) AS allRows, COUNT(phoneNo) AS withPhone FROM Member;

-- ---------------------------------------------------------------- statements that FAIL (try them one at a time)
-- INSERT INTO Member VALUES ('M01', 'Eve Lam', NULL, 'eve@mail.com');    -- duplicate PRIMARY KEY
-- INSERT INTO Booking VALUES ('M09', 'YOG1', '2026-03-06');              -- FOREIGN KEY: no member M09
-- INSERT INTO Member VALUES ('M05', 'Eve Lam', NULL, 'ava@mail.com');    -- UNIQUE email
-- INSERT INTO Member VALUES ('M05', NULL, NULL, 'eve@mail.com');         -- NOT NULL memberName
-- DELETE FROM Trainer WHERE trainerID = 'T3';                            -- T3 still has a class (child rows)
