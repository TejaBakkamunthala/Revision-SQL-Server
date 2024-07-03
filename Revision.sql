CREATE DATABASE REVISION;

USE REVISION;

--E-commerce application: Suppose you have an e-commerce application where customers can place orders, 
--and the orders need to be processed and shipped. You could create a stored procedure that takes in 
--the order details, validates the data, creates a new order in the database, updates the inventory, 
--and sends an email confirmation to the customer. This stored procedure could be called from the 
--application whenever a new order is placed.

 
CREATE TABLE Customers (
    CustomerID INT PRIMARY KEY IDENTITY(1,1),
    Name NVARCHAR(30),
    Email NVARCHAR(30)
);

SELECT * From Customers;



INSERT INTO Customers(Name,Email) VALUES
('Virat','Virat@gmail.com'),
('Rohith','rohith@gmail.com'),
('Dhoni','dhoni@gmail.com');

select * from Customers;


CREATE TABLE Products (
    ProductID INT PRIMARY KEY IDENTITY(1,1),
    Name VARCHAR(30),
    Stock INT,
    Price DECIMAL(6, 2)
);


SELECT * FROM Products;


INSERT INTO Products (Name, Stock, Price)
VALUES
('Laptop', 10, 1000),
('Smartphone', 20,500),
('Headphones', 50, 50);

CREATE TABLE Orders (
    OrderID INT PRIMARY KEY IDENTITY(1,1),
    CustomerID INT FOREIGN KEY REFERENCES Customers(CustomerID),
    OrderDate DATETIME,
    TotalAmount DECIMAL(6, 2),
    Status VARCHAR(30)
);


INSERT INTO Orders (CustomerID, OrderDate, TotalAmount, Status)
VALUES
(1, '01-01-2023', 2000, 'Pending'),
(2, '02-02-2023', 3000, 'Shipped'),    
(1, '03-03-2024', 5000, 'Processing');

SELECT * FROM ORDERS;



CREATE TABLE OrderDetails (
    OrderDetailID INT PRIMARY KEY IDENTITY(1,1),
    OrderID INT FOREIGN KEY REFERENCES Orders(OrderID),
    ProductID INT FOREIGN KEY REFERENCES products(ProductID),
    Quantity INT,
    UnitPrice DECIMAL(18, 2),
    );

	SELECT * FROM OrderDetails;

	

CREATE TYPE OrderDetailType AS TABLE
(
    ProductID INT,
    Quantity INT,
    UnitPrice DECIMAL(18, 2)
);


CREATE  or ALTER PROCEDURE PlaceOrder
    @CustomerID INT,
    @OrderDetails OrderDetailType READONLY
AS
BEGIN
    DECLARE @OrderID INT;
    DECLARE @TotalAmount DECIMAL(6, 2) = 0;
    DECLARE @Email VARCHAR(30);
    DECLARE @CustomerName VARCHAR(30);

    BEGIN TRANSACTION;

    INSERT INTO Orders (CustomerID, OrderDate, TotalAmount, Status)
    VALUES (@CustomerID, GETDATE(), @TotalAmount, 'Pending');

    SET @OrderID = SCOPE_IDENTITY();

    SELECT @TotalAmount = SUM(Quantity * UnitPrice)
    FROM @OrderDetails;

    IF EXISTS (
        SELECT 1
        FROM @OrderDetails od
        JOIN Products p ON od.ProductID = p.ProductID
        WHERE p.Stock < od.Quantity
    )
    BEGIN
        ROLLBACK TRANSACTION;
        RAISERROR ('Insufficient stock for one or more products', 16, 1);
        RETURN;
    END

    INSERT INTO OrderDetails (OrderID, ProductID, Quantity, UnitPrice)
    SELECT @OrderID, ProductID, Quantity, UnitPrice
    FROM @OrderDetails;

    UPDATE p
    SET p.Stock = p.Stock - od.Quantity
    FROM Products p
    JOIN @OrderDetails od ON p.ProductID = od.ProductID;

    UPDATE Orders
    SET TotalAmount = @TotalAmount
    WHERE OrderID = @OrderID;

    -- Commit transaction
    COMMIT TRANSACTION;

    -- Get customer email and name
    SELECT @Email = Email, @CustomerName = Name FROM Customers WHERE CustomerID = @CustomerID;

END





DECLARE @OrderDetails OrderDetailType;

INSERT INTO @OrderDetails (ProductID, Quantity, UnitPrice)
VALUES (1, 3, 999.99), -- 2 Laptops
       (2, 1, 499.99); -- 1 Smartphone

EXEC PlaceOrder @CustomerID = 1, @OrderDetails = @OrderDetails;

SELECT * FROM OrderDetails;

SELECT * FROM PRODUCTS;

SELECT * FROM ORDERS;


--JOINS
--E-commerce application: In an e-commerce application, you could use a join to retrieve the order details 
--and customer information for a specific order. For example, you could join the orders table with the 
--customers table on the customer ID to get the customers name, address, and contact information for the order.

DECLARE @OrderID INT = 4;

SELECT 
    o.OrderID,
    o.OrderDate,
    o.TotalAmount,
    o.Status,
    c.CustomerID,
    c.Name AS CustomerName,
    c.Email AS CustomerEmail,
    od.ProductID,
    p.Name AS ProductName,
    od.Quantity,
    od.UnitPrice,
    (od.Quantity * od.UnitPrice) AS Total
FROM 
    Orders o
JOIN 
    Customers c ON o.CustomerID = c.CustomerID
JOIN 
    OrderDetails od ON o.OrderID = od.OrderID
JOIN 
    Products p ON od.ProductID = p.ProductID
WHERE 
    o.OrderID = @OrderID;



	SELECT * FROM ORDERS;

	SELECT * FROM OrderDetails;


--Banking application: In a banking application, you could create a stored procedure that transfers 
--funds between accounts. The stored procedure would take in the account numbers, validate the data, 
--check the balance, and update the account balances in the database. You could also include additional 
--logic to handle currency conversions, transaction fees, and other business rules.


CREATE TABLE Accounts (
    AccountID INT PRIMARY KEY IDENTITY(1,1),
    AccountNumber VARCHAR(20) UNIQUE,
    CustomerName VARCHAR(30),
    Balance DECIMAL(10, 2)
);



INSERT INTO Accounts (AccountNumber, CustomerName, Balance)
VALUES
('ACC123', 'Virat Kohli', 5000.00),
('ACC124', 'Roith Sharma', 3000.00),
('ACC125', 'MS Dhoni', 10000.00);

select * from Accounts;


CREATE TABLE Transactions (
    TransactionID INT PRIMARY KEY IDENTITY(1,1),
    SourceAccountID INT FOREIGN KEY REFERENCES Accounts(AccountID),
    DestinationAccountID INT FOREIGN KEY REFERENCES Accounts(AccountID),
    Amount DECIMAL(10, 2),
    TransactionFee DECIMAL(10, 2),
    TransactionDate DATETIME,
  
);

INSERT INTO Transactions (SourceAccountID, DestinationAccountID, Amount, TransactionFee, TransactionDate)
VALUES
(1, 2, 100.00, 2.50, '01-01-2024'), 
(2, 3, 50.00, 1.25, '02-02-2024'),   
(3, 1, 75.00, 1.75, '03-03-2024');   

SELECT * FROM Transactions;


CREATE OR ALTER  PROCEDURE TransferFunds
    @SourceAccountNumber VARCHAR(20),
    @DestinationAccountNumber VARCHAR(20),
    @Amount DECIMAL(10, 2)
AS
BEGIN
    DECLARE @SourceAccountID INT;
    DECLARE @DestinationAccountID INT;
    DECLARE @SourceBalance DECIMAL(10, 2);
    DECLARE @DestinationBalance DECIMAL(10, 2);
    DECLARE @TransactionFee DECIMAL(10, 2) = 2.50; 
    BEGIN TRANSACTION;

    SELECT @SourceAccountID = AccountID, @SourceBalance = Balance
    FROM Accounts
    WHERE AccountNumber = @SourceAccountNumber;

    IF @SourceAccountID IS NULL
    BEGIN
        ROLLBACK TRANSACTION;
        RAISERROR('Source account not found', 16, 1);
        RETURN;
    END

    SELECT @DestinationAccountID = AccountID, @DestinationBalance = Balance
    FROM Accounts
    WHERE AccountNumber = @DestinationAccountNumber;

    IF @DestinationAccountID IS NULL
    BEGIN
        ROLLBACK TRANSACTION;
        RAISERROR('Destination account not found', 16, 1);
        RETURN;
    END

    IF @SourceBalance < @Amount + @TransactionFee
    BEGIN
        ROLLBACK TRANSACTION;
        RAISERROR('Insufficient balance in source account', 16, 1);
        RETURN;
    END

    -- Update Source Account Balance
    UPDATE Accounts
    SET Balance = Balance - @Amount - @TransactionFee
    WHERE AccountNumber = @SourceAccountNumber;

    UPDATE Accounts
    SET Balance = Balance + @Amount
    WHERE AccountNumber = @DestinationAccountNumber;

    INSERT INTO Transactions (SourceAccountID, DestinationAccountID, Amount, TransactionFee, TransactionDate)
    VALUES (@SourceAccountID, @DestinationAccountID, @Amount, @TransactionFee, GETDATE());

    COMMIT TRANSACTION;
END

SELECT * FROM Accounts;

select * from Transactions;

EXEC TransferFunds @SourceAccountNumber = 'ACC123', @DestinationAccountNumber = 'ACC124', @Amount = 100;


--Banking application: In a banking application, you could use a join to retrieve the account details
--and transaction history for a specific customer. For example, you could join the customers table with 
--the accounts table and the transactions table on the account ID to get the account balance, transaction
--dates, and amounts for the customer's account.

CREATE TABLE Customerss (
    CustomerID INT PRIMARY KEY IDENTITY(1,1),
    CustomerName VARCHAR(30),
    Address NVARCHAR(50),
    ContactNumber VARCHAR(20)
);


INSERT INTO Customerss (CustomerName, Address, ContactNumber)
VALUES
('Virat Kohli', 'btm, banglore, karataka', '123456789'),
('Rohith Shrama', 'hsr, banglore, karnataka', '1234567898'),
('MS Dhoni', 'electronic, banglore, USA', '1234567890');

select * from customers;


CREATE TABLE Accountss (
    AccountID INT PRIMARY KEY IDENTITY(1,1),
    CustomerID INT FOREIGN KEY REFERENCES Customerss(CustomerID),
    AccountNumber VARCHAR(20),
    Balance DECIMAL(10, 2),
);

INSERT INTO Accountss ( CustomerID, AccountNumber, Balance)
VALUES
( 1, 'ACC123', 5000.00),
( 2, 'ACC456', 3000.00),
( 3, 'ACC789', 10000.00);


CREATE TABLE Transactionss (
    TransactionID INT PRIMARY KEY IDENTITY(1,1),
    SourceAccountID INT FOREIGN KEY REFERENCES Accountss(AccountID),
    DestinationAccountID INT FOREIGN KEY REFERENCES Accountss(AccountID),
    Amount DECIMAL(10, 2),
    TransactionDate DATETIME,
);

INSERT INTO Transactionss ( SourceAccountID, DestinationAccountID, Amount, TransactionDate)
VALUES
( 1, 2, 100.00, '2024-06-25 10:30:00'),
( 2, 1, 50.00, '2024-06-25 11:45:00'),
 (3, 1, 200.00, '2024-06-26 09:15:00');

 SELECT * FROM Transactionss;


 SELECT
    c.CustomerID,
    c.CustomerName,
    a.AccountID,
    a.AccountNumber,
    a.Balance,
    t.TransactionID,
    t.Amount,
    t.TransactionDate
FROM
    Customerss c
JOIN
    Accountss a ON c.CustomerID = a.CustomerID
LEFT JOIN
    Transactionss t ON a.AccountID = t.SourceAccountID OR a.AccountID = t.DestinationAccountID
WHERE
    c.CustomerID = 1; 


--3.Healthcare application: In a healthcare application, you could create a stored procedure that 
--schedules appointments for patients. The stored procedure would take in the patient details, validate 
--the data, check for conflicting appointments, and create a new appointment in the database. You could 
--also include additional logic to send reminders to patients, update the doctors schedule, and handle 
--cancellations or rescheduling requests.


CREATE TABLE Patients (
    PatientID INT PRIMARY KEY IDENTITY(1,1),
    Name VARCHAR(30),
    DateOfBirth DATE,
    PhoneNumber VARCHAR(15)
);

INSERT INTO Patients ( Name, DateOfBirth, PhoneNumber) VALUES
('Virat Kohli', '1985-06-15', '1234567890'),
('Rohith Sharma', '1990-09-23', '1234567889'),
('MS Dhoni', '1978-11-05', '1234567899');

SELECT * FROM Patients;

CREATE TABLE Doctors (
    DoctorID INT PRIMARY KEY IDENTITY(1,1),
    Name VARCHAR(30),
    Specialization VARCHAR(50)
);

INSERT INTO Doctors ( Name, Specialization) VALUES
( 'Ram Charan', 'Cardiology'),
( 'Allu Arjun', 'Dermatology'),
( 'Prabhas', 'Surgeon');

SELECT * FROM Doctors;


CREATE TABLE Appointments (
    AppointmentID INT PRIMARY KEY AUTO_INCREMENT,
    PatientID INT,
    DoctorID INT,
    AppointmentDate DATETIME,
    Status VARCHAR(20),
    FOREIGN KEY (PatientID) REFERENCES Patients(PatientID),
    FOREIGN KEY (DoctorID) REFERENCES Doctors(DoctorID)
);

INSERT INTO Appointments (PatientID, DoctorID, AppointmentDate, Status) VALUES
(1, 1, '2024-07-01 10:00:00', 'Scheduled'),
(2, 2, '2024-07-01 11:00:00', 'Scheduled');


select * from Appointments;


CREATE OR ALTER PROCEDURE ScheduleAppointment
    @PatientID INT,
    @DoctorID INT,
    @AppointmentDate DATETIME,
    @Status VARCHAR(20)
AS
BEGIN
    -- Validate PatientID
    IF NOT EXISTS (SELECT 1 FROM Patients WHERE PatientID = @PatientID)
    BEGIN
        RAISERROR ('Invalid PatientID', 16, 1);
        RETURN;
    END

    -- Validate DoctorID
    IF NOT EXISTS (SELECT 1 FROM Doctors WHERE DoctorID = @DoctorID)
    BEGIN
        RAISERROR ('Invalid DoctorID', 16, 1);
        RETURN;
    END

    -- Check for conflicting appointments for the doctor
    IF EXISTS (SELECT 1 FROM Appointments 
               WHERE DoctorID = @DoctorID AND AppointmentDate = @AppointmentDate AND Status = 'Scheduled')
    BEGIN
        RAISERROR ('Conflicting appointment for the doctor', 16, 1);
        RETURN;
    END

    -- Insert the new appointment
    INSERT INTO Appointments (PatientID, DoctorID, AppointmentDate, Status)
    VALUES (@PatientID, @DoctorID, @AppointmentDate, @Status);

END


EXEC ScheduleAppointment @PatientID = 3, @DoctorID = 2, @AppointmentDate = '2024-07-01 12:00:00', @Status = 'Scheduled';

select * from Appointments;



CREATE TABLE MedicalHistory (
    HistoryID INT PRIMARY KEY IDENTITY(1,1),
    PatientID INT FOREIGN KEY REFERENCES Patients(PatientID),
    Disease VARCHAR(30),
    Treatment VARCHAR(30),
    TreatmentDate DATE,
);


INSERT INTO MedicalHistory (PatientID, Disease, Treatment, TreatmentDate) VALUES
(1, 'Hypertension', 'Medication', '2024-01-10'),
(1, 'Diabetes', 'Diet Control', '2023-06-15'),
(2, 'Asthma', 'Inhaler', '2023-11-20');
SELECT * FROM MedicalHistory;


SELECT
    a.AppointmentID,
    a.AppointmentDate,
    a.Status,
    p.Name AS PatientName,
    DATEDIFF(YEAR, p.DateOfBirth, GETDATE()) AS Age,
    p.PhoneNumber,
    mh.Disease,
    mh.Treatment,
    mh.TreatmentDate
FROM
    Appointments a
JOIN
    Patients p ON a.PatientID = p.PatientID
LEFT JOIN
    MedicalHistory mh ON p.PatientID = mh.PatientID
WHERE
    a.AppointmentID = 1;



CREATE OR ALTER PROCEDURE ScheduleAppointment
    @PatientID INT,
    @DoctorID INT,
    @AppointmentDate DATETIME,
    @Status VARCHAR(20),
    @Action VARCHAR(20)  -- 'Schedule', 'Cancel', 'Reschedule'
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @CurrentDateTime DATETIME;
    SET @CurrentDateTime = GETDATE();

    -- Validate PatientID
    IF NOT EXISTS (SELECT 1 FROM Patients WHERE PatientID = @PatientID)
    BEGIN
        RAISERROR ('Invalid PatientID', 16, 1);
        RETURN;
    END

    -- Validate DoctorID
    IF NOT EXISTS (SELECT 1 FROM Doctors WHERE DoctorID = @DoctorID)
    BEGIN
        RAISERROR ('Invalid DoctorID', 16, 1);
        RETURN;
    END

    -- Handle Scheduling
    IF @Action = 'Schedule'
    BEGIN
        -- Check for conflicting appointments for the doctor
        IF EXISTS (SELECT 1 FROM Appointments 
                   WHERE DoctorID = @DoctorID AND AppointmentDate = @AppointmentDate AND Status = 'Scheduled')
        BEGIN
            RAISERROR ('Conflicting appointment for the doctor', 16, 1);
            RETURN;
        END

        -- Insert the new appointment
        INSERT INTO Appointments (PatientID, DoctorID, AppointmentDate, Status)
        VALUES (@PatientID, @DoctorID, @AppointmentDate, @Status);

        -- Send reminder to patient (Assuming there's a SendReminder function)
        EXEC SendReminder @PatientID, @AppointmentDate;
        
        -- Update doctor's schedule (Assuming there's an UpdateDoctorSchedule function)
        EXEC UpdateDoctorSchedule @DoctorID;
    END

    -- Handle Cancellation
    ELSE IF @Action = 'Cancel'
    BEGIN
        -- Check if the appointment exists
        IF EXISTS (SELECT 1 FROM Appointments 
                   WHERE PatientID = @PatientID AND DoctorID = @DoctorID AND AppointmentDate = @AppointmentDate AND Status = 'Scheduled')
        BEGIN
            -- Update appointment status to 'Cancelled'
            UPDATE Appointments
            SET Status = 'Cancelled'
            WHERE PatientID = @PatientID AND DoctorID = @DoctorID AND AppointmentDate = @AppointmentDate;

            -- Update doctor's schedule
            EXEC UpdateDoctorSchedule @DoctorID;
        END
        ELSE
        BEGIN
            RAISERROR ('No scheduled appointment found to cancel', 16, 1);
            RETURN;
        END
    END

    -- Handle Rescheduling
    ELSE IF @Action = 'Reschedule'
    BEGIN
        DECLARE @NewAppointmentDate DATETIME;
        SET @NewAppointmentDate = @AppointmentDate;

        -- Check if the current appointment exists
        IF EXISTS (SELECT 1 FROM Appointments 
                   WHERE PatientID = @PatientID AND DoctorID = @DoctorID AND Status = 'Scheduled')
        BEGIN
            -- Check for conflicting appointments for the doctor
            IF EXISTS (SELECT 1 FROM Appointments 
                       WHERE DoctorID = @DoctorID AND AppointmentDate = @NewAppointmentDate AND Status = 'Scheduled')
            BEGIN
                RAISERROR ('Conflicting appointment for the doctor on new date', 16, 1);
                RETURN;
            END

            -- Update the appointment date and status
            UPDATE Appointments
            SET AppointmentDate = @NewAppointmentDate, Status = 'Scheduled'
            WHERE PatientID = @PatientID AND DoctorID = @DoctorID AND Status = 'Scheduled';

            -- Send reminder to patient
            EXEC SendReminder @PatientID, @NewAppointmentDate;

            -- Update doctor's schedule
            EXEC UpdateDoctorSchedule @DoctorID;
        END
        ELSE
        BEGIN
            RAISERROR ('No scheduled appointment found to reschedule', 16, 1);
            RETURN;
        END
    END

    ELSE
    BEGIN
        RAISERROR ('Invalid action. Use Schedule, Cancel or Reschedule.', 16, 1);
        RETURN;
    END
END

CREATE OR ALTER PROCEDURE SendReminder
    @PatientID INT,
    @AppointmentDate DATETIME
AS
BEGIN
    -- Example implementation of sending a reminder
    PRINT 'Reminder sent to patient ' + CAST(@PatientID AS VARCHAR) + ' for appointment on ' + CAST(@AppointmentDate AS VARCHAR);
END

CREATE OR ALTER PROCEDURE UpdateDoctorSchedule
    @DoctorID INT
AS
BEGIN
    -- Example implementation of updating doctor's schedule
    PRINT 'Schedule updated for doctor ' + CAST(@DoctorID AS VARCHAR);
END


SELECT * FROM Appointments;

EXEC ScheduleAppointment @PatientID = 1, @DoctorID = 1, @AppointmentDate = '2024-07-01 10:00:00', @Status = 'Scheduled', @Action = 'Schedule';

EXEC ScheduleAppointment @PatientID = 1, @DoctorID = 1, @AppointmentDate = '2024-07-01 10:00:00', @Status = 'Cancelled', @Action = 'Cancel';

EXEC ScheduleAppointment @PatientID = 1, @DoctorID = 1, @AppointmentDate = '2024-07-01 11:00:00', @Status = 'Scheduled', @Action = 'Reschedule';



--Travel booking application: In a travel booking application, you could create a stored procedure 
--that searches for the best flight or hotel deals based on user preferences and availability. 
--The stored procedure would query multiple databases, compare prices and availability, and generate a 
--list of options for the user. You could also include additional logic to handle cancellations or
--changes to the booking, track loyalty points or rewards, and provide personalized recommendations
--for future bookings.

CREATE TABLE Users (
    UserID INT PRIMARY KEY IDENTITY(1,1),
    UserName VARCHAR(30),
    Email VARCHAR(30) 
);

INSERT INTO Users (UserName, Email) VALUES
('Dhoni', 'dhoni@gmail.com'),
('Raina', 'raina@gmail.com');

select * from Users;



CREATE TABLE Flights (
    FlightID INT  PRIMARY KEY IDENTITY(1,1),
    Airline VARCHAR(30) NOT NULL,
    Departure VARCHAR(30) NOT NULL,
    Destination VARCHAR(30) NOT NULL,
    DepartureTime DATETIME NOT NULL,
    ArrivalTime DATETIME NOT NULL,
    Price DECIMAL(10, 2) NOT NULL
);


INSERT INTO Flights (Airline, Departure, Destination, DepartureTime, ArrivalTime, Price) VALUES
('Airline A', 'Bengulru', 'Hyderabad', '2024-07-01 08:00:00', '2024-07-01 11:00:00', 3000.00),
('Airline B', 'Benguluru', 'Pune', '2024-07-02 09:00:00', '2024-07-02 13:00:00', 2000.00),
('Airline C', 'Hyderabad', 'Mumbai', '2024-07-01 08:00:00', '2024-07-01 11:00:00', 3000.00),
('Airline D', ',Mumbai', 'Delhi', '2024-07-02 09:00:00', '2024-07-02 13:00:00', 2000.00);

select * from flights;


CREATE TABLE Hotels (
    HotelID INT  PRIMARY KEY IDENTITY(1,1),
    HotelName VARCHAR(30) NOT NULL,
    Location VARCHAR(30) NOT NULL,
    AvailableRooms INT NOT NULL,
    PricePerNight DECIMAL(10, 2) NOT NULL
);



INSERT INTO Hotels (HotelName, Location, AvailableRooms, PricePerNight) VALUES
('Hotel A', 'Hyderabad', 10, 150.00),
('Hotel B', 'Pube', 20, 100.00),
('Hotel C', 'Mumbai', 10, 300.00),
('Hotel D', 'Delhi', 20, 400.00);

select * from hotels;


CREATE TABLE Bookings (
    BookingID INT IDENTITY(1,1) PRIMARY KEY,
    UserID INT NOT NULL FOREIGN KEY REFERENCES Users(UserID),
    FlightID INT NULL FOREIGN KEY REFERENCES Flights(FlightID),
    HotelID INT NULL FOREIGN KEY REFERENCES Hotels(HotelID),
    BookingDate DATETIME NOT NULL,
   
);

INSERT INTO Bookings (UserID, FlightID, HotelID, BookingDate) VALUES
(1, 1, NULL, '2024-06-25 10:00:00'), 
(2, NULL, 1, '2024-06-26 11:00:00'), 
(1, 2, 2, '2024-06-27 12:00:00'),
(3, 1, NULL, '2024-06-25 10:00:00'), 
(4, NULL, 1, '2024-06-26 11:00:00'), 
(4, 2, 2, '2024-06-27 12:00:00');     


CREATE OR ALTER PROCEDURE BookTravel
    @UserID INT,
    @FlightID INT = NULL,
    @HotelID INT = NULL,
    @BookingDate DATETIME
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Users WHERE UserID = @UserID)
    BEGIN
        RAISERROR ('Invalid UserID', 16, 1);
        RETURN;
    END

    IF @FlightID IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Flights WHERE FlightID = @FlightID)
    BEGIN
        RAISERROR ('Invalid FlightID', 16, 1);
        RETURN;
    END

    IF @HotelID IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Hotels WHERE HotelID = @HotelID)
    BEGIN
        RAISERROR ('Invalid HotelID', 16, 1);
        RETURN;
    END

    IF @FlightID IS NOT NULL AND EXISTS (SELECT 1 FROM Bookings 
                                         WHERE UserID = @UserID AND FlightID = @FlightID )
    BEGIN
        RAISERROR ('Conflicting flight booking for the user', 16, 1);
        RETURN;
    END

    IF @HotelID IS NOT NULL AND (SELECT AvailableRooms FROM Hotels WHERE HotelID = @HotelID) < 1
    BEGIN
        RAISERROR ('No available rooms in the selected hotel', 16, 1);
        RETURN;
    END

    INSERT INTO Bookings (UserID, FlightID, HotelID, BookingDate)
    VALUES (@UserID, @FlightID, @HotelID, @BookingDate);

    IF @HotelID IS NOT NULL
    BEGIN
        UPDATE Hotels
        SET AvailableRooms = AvailableRooms - 1
        WHERE HotelID = @HotelID;
    END
END;



EXEC BookTravel 
    @UserID = 1,
    @FlightID = 1,
    @HotelID = NULL, 
    @BookingDate = '02-02-2024 11:00:00';
  
   
EXEC BookTravel 
    @UserID = 1,
    @FlightID = NULL, 
    @HotelID = 1,
    @BookingDate ='04-04-2024 12:12:12';


EXEC BookTravel 
    @UserID = 1,
    @FlightID = 2,
    @HotelID = 1,
    @BookingDate = '05-05-2024 12:00:00';
   



   EXEC BookTravel 
    @UserID = 2,
    @FlightID = 3,
    @HotelID = 2,
    @BookingDate = '05-05-2024 12:00:00';

	 SELECT* FROM Bookings;


 --Travel booking application: In a travel booking application, you could use a join to retrieve the
 --flight or hotel details and customer information for a specific booking. For example, you could join
 --the bookings table with the flights table or the hotels table and the customers table on the booking
 --ID to get the booking details, customer names, and contact information.



DECLARE @BookingID INT = 3;

SELECT 
    B.BookingID,
    U.UserName,
    U.Email,
    B.BookingDate,
    F.FlightID,
    F.Airline,
    F.Departure,
    F.Destination,
    F.DepartureTime,
    F.ArrivalTime,
    F.Price AS FlightPrice,
    H.HotelID,
    H.HotelName,
    H.Location,
    H.PricePerNight AS HotelPrice
FROM 
    Bookings B
LEFT JOIN 
    Users U ON B.UserID = U.UserID
LEFT JOIN 
    Flights F ON B.FlightID = F.FlightID
LEFT JOIN 
    Hotels H ON B.HotelID = H.HotelID
WHERE 
    B.BookingID = @BookingID;










--Gaming application: In a gaming application, you could create a stored procedure that manages the 
--players inventory and transactions. The stored procedure would update the database with the items 
--purchased or earned by the player, validate the transactions, and calculate the players balance. You 
--could also include additional logic to handle game events or achievements, track player engagement and 
--retention, and provide personalized recommendations for in-game purchases.


CREATE TABLE Players (
    PlayerID INT  PRIMARY KEY IDENTITY(1,1),
    PlayerName VARCHAR(30) NOT NULL,
    Email VARCHAR(30) NOT NULL UNIQUE,
    Balance DECIMAL(10, 2) NOT NULL
);

INSERT INTO Players (PlayerName, Email, Balance) VALUES
('Virat', 'virat@gmail.com', 100.00),
('Rohith', 'roith@gmail.com',200.00),
('Dhoni', 'dhoni@gmail.com', 300.00),
('Raina', 'raina@gmail.com', 400.00);
 
 update players set  Balance=400000 where PlayerID=4;

   
  upadte Players 

CREATE TABLE Items (
    ItemID INT PRIMARY KEY IDENTITY(1,1),
    ItemName VARCHAR(30) NOT NULL,
    ItemPrice DECIMAL(10, 2) NOT NULL
);

INSERT INTO Items (ItemName, ItemPrice) VALUES
('Bat', 5000.00),
('Ball', 3000.00),
('Gloves', 1000.00);


 CREATE TABLE PlayerInventory (
    InventoryID INT  PRIMARY KEY IDENTITY(1,1),
    PlayerID INT NOT NULL  FOREIGN KEY REFERENCES Players(PlayerID),
    ItemID INT NOT NULL FOREIGN KEY REFERENCES Items(ItemID),
    Quantity INT NOT NULL,
);

INSERT INTO PlayerInventory (PlayerID, ItemID, Quantity) VALUES
(1, 1, 1), 
(2, 2, 2),
(1, 2, 2),
(3, 3, 3);

select * from PlayerInventory;

CREATE TABLE Transactionsss (
    TransactionID INT PRIMARY KEY IDENTITY(1,1),
    PlayerID INT NOT NULL REFERENCES Players(PlayerID),
    ItemID INT NOT NULL REFERENCES Items(ItemID),
    Quantity INT NOT NULL,
    TransactionDate DATETIME NOT NULL,
);


INSERT INTO Transactionsss (PlayerID, ItemID, Quantity, TransactionDate) VALUES
(1, 1, 1, '2024-06-25 10:00:00'), 
(2, 2, 2, '2024-07-26 11:00:00'),
(3, 3, 3, '2024-08-25 10:00:00');

SELECT * FROM Transactionsss;






CREATE OR ALTER PROCEDURE ManageTransaction
    @PlayerID INT,
    @ItemID INT,
    @Quantity INT,
    @TransactionDate DATETIME
AS
BEGIN
 
    DECLARE @ItemPrice DECIMAL(10, 2);
    DECLARE @TotalPrice DECIMAL(10, 2);
    DECLARE @PlayerBalance DECIMAL(10, 2);

    IF NOT EXISTS (SELECT 1 FROM Players WHERE PlayerID = @PlayerID)
    BEGIN
        RAISERROR ('Invalid PlayerID', 16, 1);
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM Items WHERE ItemID = @ItemID)
    BEGIN
        RAISERROR ('Invalid ItemID', 16, 1);
        RETURN;
    END

    SELECT @ItemPrice = ItemPrice FROM Items WHERE ItemID = @ItemID;
    SET @TotalPrice = @ItemPrice * @Quantity;

    SELECT @PlayerBalance = Balance FROM Players WHERE PlayerID = @PlayerID;

    IF @PlayerBalance < @TotalPrice
    BEGIN
        RAISERROR ('Insufficient balance', 16, 1);
        RETURN;
    END

    UPDATE Players
    SET Balance = Balance - @TotalPrice
    WHERE PlayerID = @PlayerID;

    INSERT INTO Transactionsss (PlayerID, ItemID, Quantity, TransactionDate)
    VALUES (@PlayerID, @ItemID, @Quantity, @TransactionDate);

    IF EXISTS (SELECT 1 FROM PlayerInventory WHERE PlayerID = @PlayerID AND ItemID = @ItemID)
    BEGIN
        UPDATE PlayerInventory
        SET Quantity = Quantity + @Quantity
        WHERE PlayerID = @PlayerID AND ItemID = @ItemID;
    END
    ELSE
    BEGIN
        INSERT INTO PlayerInventory (PlayerID, ItemID, Quantity)
        VALUES (@PlayerID, @ItemID, @Quantity);
    END
END;



select * from Players;

select * from items;




EXEC ManageTransaction 
    @PlayerID = 3,
    @ItemID = 3,
    @Quantity = 2,
    @TransactionDate = '03-03-2024';


	select * from Transactionsss;


--Gaming application: In a gaming application, you could use a join to retrieve the player 
--information and game statistics for a specific game. For example, you could join the players 
--table with the game statistics table on the player ID to get the players name, age, location, and 
--game history.

CREATE TABLE GameStatistics (
    GameID INT  PRIMARY KEY IDENTITY(1,1),
    PlayerID INT NOT NULL REFERENCES Players(PlayerID),
    GameName VARCHAR(30) NOT NULL,
    Score INT NOT NULL,
    PlayDate DATETIME NOT NULL,
);

INSERT INTO GameStatistics (PlayerID, GameName, Score, PlayDate) VALUES
(1, 'Game A', 1500, '2024-06-25 10:00:00'),
(1, 'Game B', 3000, '2024-06-26 11:00:00'),
(2, 'Game C', 2000, '2024-06-27 12:00:00'),
(2, 'Game D', 4000, '2024-06-28 13:00:00');



DECLARE @PlayerID INT = 2;

SELECT 
    P.PlayerID,
    P.PlayerName,
    G.GameID,
    G.GameName,
    G.Score,
    G.PlayDate
FROM 
    Players P
INNER JOIN 
    GameStatistics G ON P.PlayerID = G.PlayerID
WHERE 
    P.PlayerID = @PlayerID;



--Customer relationship management (CRM) application: In a CRM application, you could create a
--stored procedure that manages the customer data and interactions. The stored procedure would 
--update the database with the latest customer information, track the history of interactions 
--with the customer, and generate reports on the performance of the sales and marketing activities.
--You could also include additional logic to handle customer segmentation, lead scoring, and 
--campaign management.

CREATE TABLE Customersss (
    CustomerID INT PRIMARY KEY IDENTITY(1,1),
    CustomerName VARCHAR(30),
    EmailId VARCHAR(30),
    Segment VARCHAR(50)
);

INSERT INTO Customersss (CustomerName, EmailId, Segment)
VALUES
('Virat Kohli', 'virat@gmail.com', 'Retail'),
('Rohith Sharma', 'rohith@gmail.com', 'Wholesale'),
('MS Dhonni ', 'dhoni@gmail.com', 'Enterprise');

CREATE TABLE Campaigns (
    CampaignID INT PRIMARY KEY IDENTITY(1,1),
    CampaignName NVARCHAR(100),
    StartDate DATE,
    EndDate DATE
);

INSERT INTO Campaigns (CampaignName, StartDate, EndDate)
VALUES
('Summer Sale', '2024-06-01', '2024-06-30'),
('Winter Sale', '2024-12-01', '2024-12-31'),
('Rainy Sale' ,'2024-10-10','2024-12-12'),
('Autumn Sale' ,'2024-8-8','2024-10-10');

CREATE TABLE InteractionHistory (
    InteractionID INT PRIMARY KEY IDENTITY(1,1),
    CustomerID INT FOREIGN KEY REFERENCES Customers(CustomerID),
    CampaignID INT FOREIGN KEY REFERENCES Campaigns(CampaignID),
    InteractionDate DATE,
    InteractionDetails VARCHAR(500),
);

INSERT INTO InteractionHistory (CustomerID, CampaignID, InteractionDate, InteractionDetails)
VALUES
(1, 1, '2024-06-15', 'Email sent.'),
(2, 1, '2024-06-16', 'Phone call made.'),
(3, 2, '2024-12-01', 'SMS sent.');



CREATE OR ALTER PROCEDURE ManageCustomerInteractions
    @CustomerID INT,
    @CustomerName VARCHAR(30),
    @EmailId VARCHAR(30),
    @Segment VARCHAR(50),
    @CampaignID INT,
    @InteractionDate DATE,
    @InteractionDetails VARCHAR(100)
AS
BEGIN
    -- Check if the CampaignID exists
    IF NOT EXISTS (SELECT 1 FROM Campaigns WHERE CampaignID = @CampaignID)
    BEGIN
        RAISERROR ('Invalid CampaignID', 16, 1);
        RETURN;
    END

    -- Update or Insert Customer Information
    IF EXISTS (SELECT 1 FROM Customersss WHERE CustomerID = @CustomerID)
    BEGIN
        UPDATE Customersss
        SET CustomerName = @CustomerName,
            EmailId = @EmailId,
            Segment = @Segment
        WHERE CustomerID = @CustomerID;
    END
    ELSE
    BEGIN
        INSERT INTO Customersss (CustomerName, EmailId, Segment)
        VALUES (@CustomerName, @EmailId, @Segment);

        SET @CustomerID = SCOPE_IDENTITY();
    END

    -- Insert Interaction History
    INSERT INTO InteractionHistory (CustomerID, CampaignID, InteractionDate, InteractionDetails)
    VALUES (@CustomerID, @CampaignID, @InteractionDate, @InteractionDetails);
END;


select * from InteractionHistory;

EXEC ManageCustomerInteractions 
    @CustomerID = 3,
    @CustomerName = 'Virat Koghli',
    @EmailId = 'virat@gmail.com',
    @Segment = 'Retail',
    @CampaignID = 3,
    @InteractionDate = '2024-06-20',
    @InteractionDetails = 'Following';

	
	--Customer relationship management (CRM) application: In a CRM application, you could use a 
	--join to retrieve the customer data and interaction history for a specific campaign. For example, 
	--you could join the customers table with the campaigns table and the interaction history table on 
	--the campaign ID to get the customer names, contact information, and history of interactions with 
	--the campaign.


DECLARE @CampaignID INT = 3;

SELECT 
    c.CustomerName,
    c.EmailId,
    c.Segment,
    ih.InteractionDate,
    ih.InteractionDetails
FROM 
    Customersss c
INNER JOIN 
    InteractionHistory ih ON c.CustomerID = ih.CustomerID
INNER JOIN 
    Campaigns ca ON ih.CampaignID = ca.CampaignID
WHERE 
    ca.CampaignID = @CampaignID
ORDER BY 
    ih.InteractionDate;


	



