CREATE DATABASE CursorsRevision

USE CursorsRevision;

--cursor that selects the customer_id and customer_name columns from the "customers" table. It 
--then iterates over the result set, performing operations with each fetched row. 
--The cursor is opened, fetched row by row, and closed and deallocated after the loop.


CREATE TABLE Customers (
    customerId INT PRIMARY KEY IDENTITY(1,1),
    customerName VARCHAR(30)
);

INSERT INTO Customers(customerName) Values
('Virat Kohli'),
('Rohith Sharma'),
('MS Dhoni'),
('Jasprirh Bumrah'),
('Mohammed Siraj');

select * from Customers;


DECLARE @CustomerId INT;
DECLARE @CustomerName VARCHAR(30);

DECLARE CustomerCursor CURSOR FOR 
SELECT customerId,customerName 
FROM Customers;

OPEN CustomerCursor

FETCH NEXT FROM CustomerCursor INTO @CustomerId, @CustomerName;
PRINT 'Customer Id   ' + ' Customer Name  ';

While @@FETCH_STATUS=0

BEGIN

--PRINT 'Customer Id :' +CAST(@CustomerId AS VARCHAR(10)) + ' Customer Name : '+@CustomerName;
PRINT CAST(@CustomerId AS VARCHAR(10))+'                '+@CustomerName;


FETCH NEXT FROM CustomerCursor INTO @CustomerId,@CustomerName;

END;

CLOSE CustomerCursor;

DEALLOCATE CustomerCursor;



--cursor that selects the product_id and product_name columns from the "products" table for products with a price 
--less than 50. It then updates the product_price by increasing it by 10% for each fetched row. 
--The cursor iterates over the result set, performing an update operation for each fetched row.



-- Step 1: Create the products table
CREATE TABLE Products (
    productId INT PRIMARY KEY IDENTITY(1,1),
    productName VARCHAR(50),
    productPrice DECIMAL(10, 2)
);

INSERT INTO products (productName, productPrice) VALUES
('Product A', 45.00),
('Product B', 30.00),
('Product C', 60.00),
('Product D', 25.00),
('Product E', 50.00),
('Product F', 50.00);

SELECT * FROM Products;



DECLARE @ProductId INT;
DECLARE @ProductName VARCHAR(30);
DECLARE @ProductPrice DECIMAL(10,2);


DECLARE ProductCursor CURSOR FOR
SELECT productId,ProductName,productPrice 
FROM Products WHERE productPrice<50;

OPEN ProductCursor

FETCH NEXT FROM ProductCursor INTO @ProductId,@ProductName,@ProductPrice;


WHILE @@FETCH_STATUS=0

BEGIN 

SET @ProductPrice=@ProductPrice*1.10;

UPDATE Products 
SET productPrice=@ProductPrice
where productId=@ProductId;

FETCH NEXT FROM ProductCursor INTO @ProductId,@ProductName,@ProductPrice;

END

CLOSE ProductCursor;

DEALLOCATE ProductCursor;

SELECT  * FROM Products;




--a cursor is used to select employee_id, employee_name, and department_id from the "employees" table. 
--The fetched values are then inserted into the "new_employees" table using an INSERT statement. 
--The cursor iterates over the result set, performing the insert operation for each fetched row.


CREATE TABLE Employees(
EmployeeId INT PRIMARY KEY IDENTITY(1,1),
EmployeeName VARCHAR(30),
DepartmentId INT
);


INSERT INTO Employees VALUES
('Ram Charan',1),
('NTR',2),
('Allu Arjun',3),
('Varun Tej',4),
('Prabhas',5);

select * from employees;


CREATE TABLE NewEmployees(
EmployeeId INT,
EmployeeName VARCHAR(30),
DepartmentId INT);


SELECT * FROM NewEmployees;


--Employee Cursor

DECLARE @EmployeeId INT;
DECLARE @EmployeeName VARCHAR(30);
DECLARE @DepartmentId INT;

DECLARE EmployeeCursor CURSOR FOR
SELECT EmployeeId,EmployeeName,DepartmentId 
FROM Employees

open EmployeeCursor

FETCH NEXT FROM EmployeeCursor INTO @EmployeeId,@EmployeeName,@DepartmentId;

WHILE @@FETCH_STATUS=0

BEGIN 

INSERT INTO NewEmployees(EmployeeId,EmployeeName,DepartmentId) VALUES
(@EmployeeId,@EmployeeName,@DepartmentId);

FETCH NEXT FROM EmployeeCursor INTO @EmployeeId,@EmployeeName,@DepartmentId;

END

CLOSE EmployeeCursor;

DEALLOCATE EmployeeCursor;



select * from employees;

select * from NewEmployees;




--a cursor that selects the customer_id and the count of orders (total_orders) for each customer
--from the "orders" table. The cursor then performs an UPDATE operation on the "customers" table, 
--setting the order_count column to the corresponding total_orders value. 
--The cursor iterates over the result set, updating the rows in the "customers" table for each fetched row


Create table Customerss(
CustomerId INT PRIMARY KEY IDENTITY(1,1),
CustomerName VARCHAR(30),
OrderCount INT DEFAULT 0
);


INSERT INTO Customerss(CustomerName) VALUES
('Ram'),('Charan'),('Allu'),('Arjun');

select * from Customerss;


Create TABLE Orders(
OrderId INT PRIMARY KEY IDENTITY(1,1),
CustomerId INT FOREIGN KEY REFERENCES Customerss(CustomerId),
OrderDate DATE
);

INSERT INTO Orders(CustomerId,OrderDate) VALUES
(1,'2024-04-04'),
(1,'2024-05-05'),
(1,'2024-06-06'),
(2,'2023-12-12'),
(2,'2023-11-11'),
(3,'2022-11-11');

INSERT INTO Orders(CustomerId,OrderDate) VALUES
(2,'2024-04-04');

select * from orders;

DECLARE @CustomerId INT;
DECLARE @TotalOrders INT;

DECLARE OrderCursor  CURSOR FOR
Select CustomerId,COUNT(OrderId) as TotalOrders 
FROM Orders
GROUP BY CustomerId;

OPEN OrderCursor

FETCH NEXT FROM OrderCursor INTO @CustomerId,@TotalOrders;

WHILE @@FETCH_STATUS = 0

BEGIN

UPDATE Customerss 
SET OrderCount=@TotalOrders
where CustomerId=@CustomerId;

FETCH NEXT FROM OrderCursor INTO @CustomerId,@TotalOrders;

END;

CLOSE OrderCursor;

DEALLOCATE OrderCursor;



SELECT * FROM ORDERS;

SELECT* FROM Customerss;




