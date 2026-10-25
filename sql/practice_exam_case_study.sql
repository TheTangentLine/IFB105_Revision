-- IFB105 Practice Exam case study (Event / Ticket / Orders / Customer / Extras).
-- Built from the case-study RMap and tables. Use it to check your answers to Q22-Q25.

DROP DATABASE IF EXISTS practice_case_study;
CREATE DATABASE practice_case_study;
USE practice_case_study;
CREATE TABLE Event (eventID INT PRIMARY KEY, eventName VARCHAR(80) NOT NULL, eventLocation VARCHAR(80) NOT NULL,
  dateTime DATETIME NOT NULL, eventCategory VARCHAR(20) NOT NULL);
CREATE TABLE Customer (customerID INT PRIMARY KEY, firstName VARCHAR(30) NOT NULL, lastName VARCHAR(30) NOT NULL,
  email VARCHAR(60) NOT NULL UNIQUE, phoneNo VARCHAR(15) NOT NULL UNIQUE);
CREATE TABLE Orders (orderID INT PRIMARY KEY, customerID INT NOT NULL, totalPrice DECIMAL(8,2) NOT NULL,
  FOREIGN KEY (customerID) REFERENCES Customer(customerID));
CREATE TABLE Ticket (
  ticketID INT PRIMARY KEY AUTO_INCREMENT,
  eventID INT NOT NULL,
  orderID INT NOT NULL,
  category ENUM('Child','Adult','VIP','Concession'),
  seatNo VARCHAR(15),
  FOREIGN KEY (orderID) REFERENCES Orders(orderID),
  FOREIGN KEY (eventID) REFERENCES Event(eventID));
CREATE TABLE Extras (extraID INT PRIMARY KEY, orderID INT NOT NULL, extraType VARCHAR(30) NOT NULL, quantity INT, notes VARCHAR(80),
  FOREIGN KEY (orderID) REFERENCES Orders(orderID));
INSERT INTO Event VALUES (1,'Giants Unearthed: Megafauna','Brisbane Museum of Paleontology','2025-05-16 10:00:00','Exhibit'),
 (2,'Giants Unearthed: Megafauna','Brisbane Museum of Paleontology','2025-05-16 14:00:00','Exhibit'),
 (3,'Strawberry Sunrise: The Punnet Squares Tour','South Bank Stadium','2025-05-20 18:00:00','Concert'),
 (4,'SuperCon','Woolloongabba Convention and Exhibition Centre','2025-05-30 09:00:00','Expo'),
 (5,'Queen''s Gambit 3: The Reckoning','CBD Cinemas','2025-06-01 13:00:00','Cinema');
INSERT INTO Customer VALUES (1,'Holly','Richardson','h.rich@email.com','0412345678'),(2,'Mel','Clunes','bluesclunes@email.com','0498765432'),
 (3,'Ted','Mendling','big.ted@email.com','0456123789'),(4,'Ian','Lee','i.lee@email.com','0493827165');
INSERT INTO Orders VALUES (1,3,66.00),(2,1,126.30),(3,2,356.25),(4,1,64.00),(5,4,59.00);
INSERT INTO Ticket VALUES (1,1,1,'Child',NULL),(2,1,1,'Adult',NULL),(3,1,1,'Adult',NULL),(4,3,2,'Concession','A-31-15'),
 (5,3,2,'Concession','A-31-16'),(6,2,4,'VIP',NULL),(7,2,4,'VIP',NULL),(8,4,3,NULL,NULL),(9,4,3,NULL,NULL),(10,4,3,NULL,NULL),
 (11,5,5,'Child','J-6'),(12,5,5,'Concession','J-7'),(13,5,5,'Concession','J-8'),(14,5,5,'Child','J-9');
INSERT INTO Extras VALUES (1,5,'Popcorn',2,'1 small, 1 large'),(2,5,'Soft drink',1,NULL),(3,2,'Accessibility',NULL,'Wheelchair accessible seat'),
 (4,2,'Guided Tour',NULL,NULL);

-- ---------------------------------------------------------------- Q25 queries
SELECT firstName, lastName FROM Customer WHERE customerID IN (
  SELECT customerID FROM Orders WHERE orderID IN (SELECT DISTINCT orderID FROM Ticket WHERE category = 'VIP'));
SELECT orderID FROM Ticket GROUP BY orderID HAVING COUNT(*) > 2
EXCEPT
SELECT orderID FROM Orders WHERE totalPrice < 100;
SELECT DISTINCT Extras.orderID FROM Extras INNER JOIN Ticket ON Ticket.orderID = Extras.orderID WHERE Ticket.category = 'Child';
SELECT totalPrice FROM Orders LEFT JOIN Extras ON Orders.orderID = Extras.orderID WHERE Extras.notes IS NULL AND quantity IS NOT NULL;

-- ---------------------------------------------------------------- Q24
SELECT firstName, lastName, email FROM Customer WHERE customerID IN (
  SELECT customerID FROM Orders GROUP BY customerID HAVING SUM(totalPrice) > 100);
