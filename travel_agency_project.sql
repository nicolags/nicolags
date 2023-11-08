CREATE DATABASE Travel_Agency;

USE Travel_Agency;

CREATE TABLE Customers (
	CustomerID INT PRIMARY KEY,
    FirstName VARCHAR(50),
    LastName VARCHAR(50),
    Email VARCHAR(100),
    Phone VARCHAR(20),
    Address VARCHAR(255)
);

CREATE TABLE Destinations (
    DestinationID INT PRIMARY KEY,
    DestinationName VARCHAR(100),
    Country VARCHAR(50),
    Description TEXT
);

CREATE TABLE Packages (
    PackageID INT PRIMARY KEY,
    PackageName VARCHAR(100),
    DestinationID INT,
    StartDate DATE,
    EndDate DATE,
    Price DECIMAL(10, 2),
    FOREIGN KEY (DestinationID) REFERENCES Destinations(DestinationID)
);

CREATE TABLE Bookings (
    BookingID INT PRIMARY KEY,
    CustomerID INT,
    PackageID INT,
    BookingDate DATE,
    TotalAmount DECIMAL(10, 2),
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID),
    FOREIGN KEY (PackageID) REFERENCES Packages(PackageID)
);

CREATE TABLE Payments (
    PaymentID INT AUTO_INCREMENT PRIMARY KEY,
    BookingID INT,
    PaymentDate DATE,
    Amount DECIMAL(10, 2),
    FOREIGN KEY (BookingID) REFERENCES Bookings(BookingID)
);

CREATE TABLE BookingHistory (
    BookingID INT,
    CustomerID INT,
    PackageID INT,
    BookingDate DATE,
    FOREIGN KEY (BookingID) REFERENCES Bookings(BookingID),
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID),
    FOREIGN KEY (PackageID) REFERENCES Packages(PackageID)
);

INSERT INTO Customers (CustomerID, firstname, lastname, Email, Phone, Address)
VALUES (1, 'Ashleigh', 'Smith', 'ashsmith@gmail.com', 01235416, '60 Steven Road'),
       (2, 'Rob', 'Stephen', 'robste@gmail.com', 03525676, '75 Savers Road'),
       (3, 'Karen', 'Store', 'karsto@gmail.com', 03474636, '82 Princess Street'),
       (4, 'Mike', 'Cannoly', 'mikcan@gmail.com', 03712458, '29 Stoven Road'),
       (5, 'Rose', 'Jones', 'rosjon@gmail.com', 01735672, '812 Fishers Close' );

INSERT INTO Destinations (DestinationID, DestinationName, Country, Description)
VALUES (6, 'Miami', 'USA', 'Sunny beaches and the best nightlife'),
    (7, 'St Vincent', 'Saint Vincent and the Grenadines', 'Relaxing tropical paradise in the Caribbean'),
    (8, 'Marmaris', 'Turkey', 'Exciting excursions, sunny beaches and scenic landscapes');


INSERT INTO Packages (PackageID, PackageName, DestinationID, StartDate, EndDate, Price)
VALUES 
    (1, 'Miami Beach Getaway', 6, '2023-05-10', '2023-05-17', 1200.00),
    (2, 'Caribbean Adventure', 7, '2023-06-05', '2023-06-12', 1800.50),
    (3, 'Historical Turkey Tour', 8, '2023-07-20', '2023-07-30', 2200.75);

INSERT INTO Bookings (BookingID, CustomerID, PackageID, BookingDate, TotalAmount)
VALUES 
    (12, 3, 1, '2023-04-23', 150.99),
    (13, 1, 2, '2023-03-12', 345.80),
    (14, 4, 3, '2023-01-18', 750.29),
    (15, 2, 1, '2023-02-19', 475.43),
    (16, 5, 2, '2023-01-01', 910.70);


INSERT INTO Payments (PaymentID, BookingID, PaymentDate, Amount)
VALUES 
    (17, 12, '2023-04-25', 150.99),
    (18, 13, '2023-03-15', 345.80),
    (19, 14, '2023-01-20', 750.29),
    (20, 15, '2023-02-22', 475.43),
    (21, 16, '2023-01-05', 910.70);

CREATE VIEW BookingDetails AS
SELECT b.BookingID, c.FirstName, c.LastName, p.PackageName, p.StartDate, p.EndDate, b.BookingDate, b.TotalAmount
FROM Bookings b
JOIN Customers c ON b.CustomerID = c.CustomerID
JOIN Packages p ON b.PackageID = p.PackageID;

SELECT * FROM BookingDetails;

SELECT c.FirstName, c.LastName, b.TotalAmount
FROM Customers c
JOIN Bookings b ON c.CustomerID = b.CustomerID
WHERE b.TotalAmount > (
    SELECT AVG(TotalAmount)
    FROM Bookings
);

DELIMITER //

CREATE FUNCTION CalculateDiscount(totalAmount DECIMAL(10, 2)) RETURNS DECIMAL(10, 2)
DETERMINISTIC
BEGIN   
   DECLARE discount DECIMAL(10, 2);
    IF totalAmount > 800 THEN
        SET discount = totalAmount * 0.1;
    ELSE
        SET discount = 0;
    END IF;
    RETURN discount;
END//

DELIMITER ;

SELECT BookingID, TotalAmount, CalculateDiscount(TotalAmount) AS Discount
FROM Bookings;

DELIMITER //
CREATE PROCEDURE GetPackageDetails(IN packageID INT)
BEGIN
    SELECT * FROM Packages WHERE PackageID = packageID;
END//
DELIMITER ;

CALL GetPackageDetails(1);

DELIMITER //

CREATE PROCEDURE GetTotalSpending(IN customerID INT)
BEGIN
    DECLARE totalSpending DECIMAL(10, 2);

    SELECT SUM(TotalAmount) INTO totalSpending
    FROM Bookings
    WHERE CustomerID = customerID;

    SELECT SUM(Amount) INTO totalSpending
    FROM Payments
    WHERE BookingID IN (SELECT BookingID FROM Bookings WHERE CustomerID = customerID);

    SELECT totalSpending AS TotalSpending;
END//

DELIMITER ;

DELIMITER //
CREATE TRIGGER BeforeBookingInsert
BEFORE INSERT ON Bookings
FOR EACH ROW
BEGIN
    DECLARE maxBookingID INT;
    SET maxBookingID = (SELECT MAX(BookingID) FROM Bookings);
    IF maxBookingID IS NULL THEN
        SET maxBookingID = 0;
    END IF;
    SET NEW.BookingID = maxBookingID + 1;
END//
DELIMITER ;

INSERT INTO Bookings (CustomerID, PackageID, BookingDate, TotalAmount)
VALUES (1, 1, '2023-11-05', 200.00);
