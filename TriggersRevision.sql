CREATE DATABASE TriggersRevision

USE TriggersRevision

--Healthcare application: In a healthcare application, you could create a trigger that logs the changes made to the
--patients medical history table. The trigger would be fired automatically when an update or delete operation is 
--performed on the medical history table, and it would insert a new record into the audit log table with the details of 
--the change, such as the user who made the change and the timestamp.

CREATE TABLE Patients (
    PatientId INT PRIMARY KEY IDENTITY(1,1),
    FirstName VARCHAR(30),
    LastName VARCHAR(30),
    DateOfBirth DATE,
    Gender VARCHAR(10)
);

INSERT INTO Patients (FirstName, LastName, DateOfBirth, Gender)
VALUES
('Ram', 'Charan', '1990-01-01', 'Male'),
('Vraun Tej', 'Smith', '1991-02-02', 'Male'),
('Allu', 'Arjun', '1992-01-01', 'Male'),
('Keerthi', 'Suresh', '1993-03-03', 'Female');

select  * from Patients;


CREATE TABLE MedicalHistory (
    MedicalHistoryId INT PRIMARY KEY IDENTITY(1,1),
    PatientId INT FOREIGN KEY REFERENCES Patients(PatientId),
    Disease VARCHAR(30),
    Treatment VARCHAR(30),
    DateRecorded DATETIME DEFAULT GETDATE()
);


INSERT INTO MedicalHistory (PatientId, Disease, Treatment)
VALUES
(1, 'Fever', 'Treatment A'),
(2, 'Cough', 'Treatment B'),
(3, 'Cold', 'Treatment C'),
(4, 'Fever', 'Treatment D'),
(1, 'Dandruff','Treatement E');

SELECT * FROM MedicalHistory;


CREATE TABLE AuditLog (
    AuditId INT PRIMARY KEY IDENTITY(1,1),
    MedicalHistoryId INT ,
    Operation VARCHAR(10),
    ChangedBy VARCHAR(10),
    ChangeDate DATETIME DEFAULT GETDATE(),
    OldDisease VARCHAR(30),
    OldTreatment VARCHAR(30),
);

select * from AuditLog;





CREATE OR ALTER TRIGGER Audit_MedicalHistory
ON MedicalHistory
AFTER UPDATE, DELETE
AS
BEGIN
    DECLARE @Operation ARCHAR(10);
    DECLARE @ChangedBy VARCHAR(20) = 'admin';

	
    IF EXISTS (SELECT * FROM INSERTED)
    BEGIN
        SET @Operation = 'UPDATE';
        INSERT INTO AuditLog (MedicalHistoryId, Operation, ChangedBy, ChangeDate, OldDisease, OldTreatment)
        SELECT 
            d.MedicalHistoryId, 
            @Operation, 
            @ChangedBy, 
            GETDATE(), 
            d.Disease, 
            d.Treatment
        FROM DELETED d;
    END

	--delete
    IF EXISTS (SELECT * FROM DELETED)
    BEGIN
        SET @Operation = 'DELETE';
        INSERT INTO AuditLog (MedicalHistoryId, Operation, ChangedBy, ChangeDate, OldDisease, OldTreatment)
        SELECT 
            d.MedicalHistoryId, 
            @Operation, 
            @ChangedBy, 
            GETDATE(), 
            d.Disease, 
            d.Treatment
        FROM DELETED d;
    END
END;

select * from MedicalHistory;

select * from AuditLog;

UPDATE MedicalHistory
SET Disease = 'OCDD', Treatment = 'Treatmet O'
WHERE MedicalHistoryId = 1;


DELETE FROM MedicalHistory
WHERE MedicalHistoryId = 5;



--Banking application: In a banking application, you could create a trigger that updates the customers
--credit score when a new transaction is made. The trigger would be fired automatically when a new transaction is 
--inserted into the transactions table, and it would execute the credit score calculation code to update the customers
--credit score based on the transaction amount and type.


CREATE TABLE Customers (
    customerId INT PRIMARY KEY IDENTITY(1,1),
    customerName VARCHAR(30),
    creditScore INT
);


INSERT INTO Customers ( customerName, creditScore)
VALUES
    ( 'Virat Kohli', 750),
    ( 'Rohith Sharma ', 800),
    ( 'Bumrah ', 700);

	select * from Customers;


	CREATE TABLE Transactions (
    transactionId INT PRIMARY KEY IDENTITY(1,1),
    customerId INT FOREIGN KEY REFERENCES Customers(CustomerId),
    transactionAmount INT,
    transactionType VARCHAR(30),
    transactionDate DATE DEFAULT GETDATE()
);

INSERT INTO Transactions ( customerId, transactionAmount, transactionType)
VALUES
    ( 1, 1000, 'Deposit'),
    ( 2, 500, 'Withdrawal'),
	( 3, 2000, 'Deposit');

	select * from Transactions;

CREATE TABLE AuditCreditScore (
    auditId INT  PRIMARY KEY IDENTITY(1,1),
    customerId INT FOREIGN KEY REFERENCES Customers(customerId),
    oldCreditScore INT,
    newCreditScore INT,
    changeDate DATETIME DEFAULT GETDATE(),
    changedBy VARCHAR(100) 
);

select * from AuditCreditScore;


CREATE OR ALTER TRIGGER UpdateCreditScore
ON Transactions
AFTER INSERT
AS
BEGIN

    DECLARE @CustomerID INT;
    DECLARE @TransactionAmount INT;
    DECLARE @TransactionType VARCHAR(30);
    DECLARE @OldCreditScore INT;
    DECLARE @NewCreditScore INT;

    SELECT 
        @CustomerID = i.customerId,
        @TransactionAmount = i.transactionAmount,
        @TransactionType = i.transactionType
    FROM inserted i;

    SELECT @OldCreditScore = c.creditScore
    FROM Customers c
    WHERE c.customerId = @CustomerID;

    IF @TransactionType = 'Deposit'
    BEGIN
        SET @NewCreditScore = @OldCreditScore + ROUND(@TransactionAmount / 100,0); 
    END
    ELSE IF @TransactionType = 'Withdrawal'
    BEGIN
        SET @NewCreditScore = @OldCreditScore - ROUND(@TransactionAmount / 100, 0); 
    END
    ELSE
    BEGIN
        SET @NewCreditScore = @OldCreditScore; -- No change for other transaction types
    END;

    UPDATE Customers
    SET creditScore = @NewCreditScore
    WHERE customerId = @CustomerID;

    -- Audit the credit score change
    INSERT INTO AuditCreditScore (customerId, oldCreditScore, newCreditScore, changeDate, changedBy)
    VALUES (@CustomerID, @OldCreditScore, @NewCreditScore, GETDATE(), 'admin'); 
END;





INSERT INTO Transactions (customerId, transactionAmount, transactionType)
VALUES ( 2, 4000, 'Deposit');

select * from transactions;

select * from customers;

select *from auditCreditScore;


--Travel booking application: In a travel booking application, you could create a trigger that updates the flight or 
--hotel availability when a booking is made. The trigger would be fired automatically when a new booking is inserted
--into the bookings table, and it would execute the availability update code to adjust the availability based on the booking details.


CREATE TABLE Users (
    UserId INT PRIMARY KEY IDENTITY(1,1),
    UserName VARCHAR(30),
    Email VARCHAR(30)
);

INSERT INTO Users (UserName, Email)
VALUES
('Ram Charan', 'ramchararn@gmail.com'),
('Allu Arjun', 'alluarjun@gmail.com'),
('Varun Tej','varun@gmail.com'),
('Prabhas','prabhas@gmail.com');

select * from Users;


CREATE TABLE Flights (
    FlightId INT PRIMARY KEY IDENTITY(1,1),
    FlightNumber VARCHAR(10),
    Capacity INT,
    AvailableSeats INT
);

INSERT INTO Flights ( FlightNumber, Capacity, AvailableSeats)
VALUES
('FL123', 150, 150),
( 'FL456', 200, 180),
( 'FL789', 180, 180);

select * from flights;


CREATE TABLE Hotels (
    HotelId INT PRIMARY KEY IDENTITY(1,1),
    HotelName VARCHAR(30),
    TotalRooms INT,
    AvailableRooms INT
);

INSERT INTO Hotels ( HotelName, TotalRooms, AvailableRooms)
VALUES
('Hotel A', 100, 100),
('Hotel B', 150, 130),
('Hotel C', 200, 180);

SELECT * FROM Hotels;


CREATE TABLE Bookings (
    BookingId INT PRIMARY KEY IDENTITY(1,1),
    UserId INT FOREIGN KEY REFERENCES Users(UserId),
    BookingType VARCHAR(10), -- 'Flight' or 'Hotel'
    FlightId INT FOREIGN KEY REFERENCES Flights(FlightId),
    HotelId INT FOREIGN KEY REFERENCES Hotels(HotelId),
    BookingDate DATE,
    NumberOfSeatsOrRooms INT,
);

INSERT INTO Bookings (UserID, BookingType, FlightID, HotelID, BookingDate, NumberOfSeatsOrRooms)
VALUES
(1, 'Flight', 1, NULL, '2024-07-01', 2),
(2, 'Hotel', NULL, 2, '2024-08-02', 1),
(3, 'Flight', 1, NULL, '2024-09-01', 3),
(4,'Hotel', NULL, 2, '2024-07-10', 4);

select * from bookings;


CREATE TABLE BookingsAudit (
    AuditID INT PRIMARY KEY IDENTITY(1,1),
    ReferenceType VARCHAR(10), -- 'Flight' or 'Hotel'
    ReferenceID INT,
    OldAvailability INT,
    NewAvailability INT,
    ChangeDate DATETIME
);


CREATE OR ALTER TRIGGER UpdateAvailabilityTrigger
ON Bookings
AFTER INSERT
AS
BEGIN
    DECLARE @BookingType NVARCHAR(10);
    DECLARE @FlightId INT;
    DECLARE @HotelId INT;
    DECLARE @NumberOfSeatsOrRooms INT;
    DECLARE @OldAvailability INT;
    DECLARE @NewAvailability INT;

    SELECT @BookingType = i.BookingType, 
           @FlightId = i.FlightId, 
           @HotelId = i.HotelId,
           @NumberOfSeatsOrRooms = i.NumberOfSeatsOrRooms
    FROM inserted i;

    IF @BookingType = 'Flight'
    BEGIN
        SELECT @OldAvailability = AvailableSeats
        FROM Flights
        WHERE FlightID = @FlightID;
        
        SET @NewAvailability = @OldAvailability - @NumberOfSeatsOrRooms;
        
        UPDATE Flights
        SET AvailableSeats = @NewAvailability
        WHERE FlightId = @FlightId;

        INSERT INTO AvailabilityAudit (ReferenceType, ReferenceID, OldAvailability, NewAvailability, ChangeDate)
        VALUES ('Flight', @FlightID, @OldAvailability, @NewAvailability, GETDATE());
    END
    ELSE IF @BookingType = 'Hotel'
    BEGIN
        SELECT @OldAvailability = AvailableRooms
        FROM Hotels
        WHERE HotelID = @HotelID;
        
        SET @NewAvailability = @OldAvailability - @NumberOfSeatsOrRooms;
        
        UPDATE Hotels
        SET AvailableRooms = @NewAvailability
        WHERE HotelID = @HotelID;

        INSERT INTO BookingsAudit (ReferenceType, ReferenceID, OldAvailability, NewAvailability, ChangeDate)
        VALUES ('Hotel', @HotelID, @OldAvailability, @NewAvailability, GETDATE());
    END
END;



INSERT INTO Bookings (UserId, BookingType, FlightId, HotelId, BookingDate, NumberOfSeatsOrRooms)
VALUES (3, 'Flight', 2, NULL, '2024-07-03', 4);

INSERT INTO Bookings (UserId, BookingType, FlightId, HotelId, BookingDate, NumberOfSeatsOrRooms)
VALUES (4, 'Hotel', NULL, 3, '2024-07-04', 4);


select * from bookings;

select * from BookingsAudit;

select * from users;



select * from hotels;

select * from flights;


--Gaming application: In a gaming application, you could create a trigger that updates the players profile and 
--generates rewards when a new achievement is unlocked. The trigger would be fired automatically when an insert 
--operation is performed on the achievements table, and it would execute the profile update and reward generation 
--code to update the players profile and provide rewards for the achievement.


CREATE TABLE Players (
    PlayerId INT PRIMARY KEY IDENTITY(1,1),
    PlayerName VARCHAR(30),
    ProfileData VARCHAR(100),
    Rewards INT DEFAULT 0
);


INSERT INTO Players ( PlayerName, ProfileData, Rewards) VALUES
('Virat Kohli', 'Profile information for Virat kohli', 10),
('Rohith Sharma', 'Profile information  for Rohith Shrama', 20),
('Dhoni','Profile information for Dhoni',30);

SELECT * FROM Players;


CREATE TABLE Achievements (
    AchievementId INT PRIMARY KEY IDENTITY(1,1),
    AchievementName VARCHAR(30),
    RewardPoints INT
);


INSERT INTO Achievements ( AchievementName, RewardPoints) VALUES
( 'First Winner', 100),
( 'Second Winner', 200),
('Third Winner',300);

SELECT *FROM Achievements;



CREATE TABLE PlayerAchievements (
    PlayerID INT FOREIGN KEY REFERENCES Players(PlayerId),
    AchievementID INT FOREIGN KEY REFERENCES Achievements(AchievementId),
    DateUnlocked DATETIME DEFAULT GETDATE(),
);


INSERT INTO PlayerAchievements (PlayerID, AchievementID) VALUES
(1, 1),
(2, 2);


SELECT * FROM PlayerAchievements;





CREATE TABLE Audit (
    AuditId INT PRIMARY KEY IDENTITY(1,1),
    PlayerId INT FOREIGN KEY REFERENCES Players(PlayerId),
    AchievementId INT FOREIGN KEY REFERENCES Achievements(AchievementId),
    ChangeTime DATE DEFAULT GETDATE()
);

  select * from Audit;


 CREATE OR ALTER TRIGGER UpdateProfileAndGenerateRewards
ON PlayerAchievements
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @PlayerID INT, @AchievementID INT, @RewardPoints INT;
    
   SELECT @PlayerID = inserted.PlayerID, @AchievementID = inserted.AchievementID
    FROM inserted;
    
    SELECT @RewardPoints = RewardPoints
    FROM Achievements
    WHERE AchievementID = @AchievementID;
    
    UPDATE Players
    SET Rewards = Rewards + @RewardPoints
    WHERE PlayerID = @PlayerID;
    
    INSERT INTO Audit (PlayerID, AchievementID)
    VALUES (@PlayerID, @AchievementID);
END;

INSERT INTO PlayerAchievements (PlayerID, AchievementID) VALUES (2, 3);

select * from PlayerAchievements;

select * from Players;

select * from Achievements;

select * from Audit;


--Customer relationship management (CRM) application: In a CRM application, you could create a trigger that 
--updates the lead score and sends a notification to the sales team when a new lead is added. 
--The trigger would be fired automatically when a new record is inserted into the leads table, 
--and it would execute the lead scoring and notification code to update the lead score and notify the 
--sales team of the new lead.

CREATE TABLE Leads (
    LeadId INT PRIMARY KEY IDENTITY(1,1),
    LeadName VARCHAR(30),
    ContactInfo VARCHAR(100),
    LeadScore INT 
);


INSERT INTO Leads ( LeadName, ContactInfo, LeadScore) VALUES
('BridgeLabz', 'bridgelabz@gmail.com', 50),
('Wipro', 'wipro@gmail.com', 70);

select * from Leads;


CREATE TABLE SalesTeam (
    SalesId INT PRIMARY KEY IDENTITY(1,1),
    SalesName VARCHAR(30),
    Email VARCHAR(30)
);

INSERT INTO SalesTeam ( SalesName, Email) VALUES
('Virat Kohli', 'virat Kohli@gmail.com'),
('Rohith Sharma', 'rohithsharma@gmail.com'),
('Dhoni','dhoni@gmail.com');

select * from SalesTeam;


CREATE TABLE LeadScores (
    LeadID INT FOREIGN KEY REFERENCES Leads(LeadId),
    Score INT,
    );

INSERT INTO LeadScores (LeadId, Score) VALUES
(1, 50),
(2, 70);

select * from LeadScores;
select * from Leads;

CREATE TABLE AuditCRM (
    AuditId INT PRIMARY KEY IDENTITY(1,1),
    LeadID INT FOREIGN KEY REFERENCES Leads(LeadId),
    ChangeType VARCHAR(50),
    ChangeTime DATETIME DEFAULT GETDATE()
);

CREATE OR ALTER TRIGGER UpdateLeadScoreAndNotify
ON Leads
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @LeadID INT, @LeadScore INT;
    
    SELECT @LeadID = inserted.LeadID, @LeadScore = inserted.LeadScore
    FROM inserted;
    
    INSERT INTO LeadScores (LeadID, Score)
    VALUES (@LeadID, @LeadScore);
    
    INSERT INTO AuditCRM (LeadID, ChangeType)
    VALUES (@LeadID, 'New lead added and scored');
    
 
END;




INSERT INTO Leads (LeadName, ContactInfo, LeadScore) 
VALUES ( 'Infosys', 'infosys@gmail.com', 100);

SELECT * FROM Leads;

SELECT * FROM LeadScores;

SELECT * FROM AuditCRM;
