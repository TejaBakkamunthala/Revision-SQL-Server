CREATE DATABASE FunctionRevision

USE FunctionRevision;

CREATE TABLE orders (
    orderId INT PRIMARY KEY IDENTITY(1,1),
    orderDate DATE,
    customerName VARCHAR(30)
);

INSERT INTO orders ( orderDate, customerName) VALUES
('2024-07-07', 'Virat Kohli'),
( '2024-08-08', 'Rohith Sharma'),
( '2024-09-09','Dhoni');

select * from Orders;


CREATE TABLE orderDetails (
    orderDetailId INT PRIMARY KEY IDENTITY(1,1),
    orderId INT FOREIGN KEY REFERENCES Orders(OrderId),
    productName VARCHAR(30),
    quantity INT,
    price DECIMAL(10, 2),
);



INSERT INTO orderDetails ( orderId, productName, quantity, price) VALUES
( 1, 'Laptop', 2, 1000),
( 1, 'Mouse', 3, 25),
( 2, 'Keyboard', 1, 50),
( 2, 'Monitor', 2, 200);


SELECT * FROM orderDetails;


CREATE  OR ALTER FUNCTION GetOrderTotal(@orderId INT)
RETURNS DECIMAL(10, 2)
AS
BEGIN
    DECLARE @total DECIMAL(10, 2);
    
    SELECT @total = SUM(quantity * price)
    FROM orderDetails
    WHERE orderId = @orderId;

   RETURN ISNULL(@total, 0);
END;


SELECT 
    orderId,
    dbo.GetOrderTotal(orderId) AS totalAmount
FROM 
    orders;


--2.a table-valued function called GetProductsWithLowStock. 
--It returns a result set containing the product_id, product_name, and stock_quantity columns 
--from the "products" table for products that have a stock quantity less than 10.

CREATE TABLE products (
    productId INT PRIMARY KEY IDENTITY(1,1),
    productName VARCHAR(30),
    stockQuantity INT
);

INSERT INTO products ( productName, stockQuantity) VALUES
( 'Laptop', 5),
( 'Mouse', 20),
( 'Keyboard', 8),
( 'Monitor', 15),
( 'USB', 2);

SELECT * FROM Products;

CREATE OR ALTER FUNCTION GetProductsWithLowStock()
RETURNS TABLE
AS
RETURN
(
    SELECT 
        productId,
        productName,
        stockQuantity
    FROM 
        products
    WHERE 
        stockQuantity < 10
);



SELECT 
    productId,
    productName,
    stockQuantity
FROM 
    dbo.GetProductsWithLowStock();

--3.table-valued function called GetOrdersByCustomer.
--It returns a result set containing the order_id, order_date, and total_amount columns from the "orders" 
--table for orders associated with a specific customer_id.


CREATE TABLE Customers (
    customerId INT PRIMARY KEY IDENTITY(1,1),
    customerName VARCHAR(30)
);

INSERT INTO Customers ( customerName) VALUES
('Virat Kohli'),
( 'Rohith Sharma'),
('Dhoni');

select * from Customers;


CREATE TABLE Orderss (
    orderId INT PRIMARY KEY IDENTITY(1,1),
    customerId INT FOREIGN KEY REFERENCES Customers(CustomerId),
    orderDate DATE,
    totalAmount DECIMAL(10, 2),
);

select * from Orderss;

INSERT INTO orderss ( customerId, orderDate, totalAmount) VALUES
( 1, '2024-07-07', 150),
( 1, '2024-08-02', 200),
( 1, '2024-09-03', 350),
 (2, '2024-01-07', 150),
( 2, '2024-10-02', 200),
( 3, '2024-11-03', 350);


CREATE OR ALTER FUNCTION GetOrdersByCustomer(@customerId INT)
RETURNS TABLE
AS
RETURN
(
    SELECT 
        orderId,
        orderDate,
        totalAmount
    FROM 
        orderss
    WHERE 
        customerId = @customerId
);



SELECT 
    orderId,
    orderDate,
    totalAmount
FROM 
    dbo.GetOrdersByCustomer(2);  


 --4.aggregate function called GetTotalOrderAmountByCustomer. It calculates and returns the total order 
 --amount for a specific customer_id by summing the total_amount column in the "orders" table.


CREATE OR ALTER FUNCTION GetTotalOrderAmountByCustomer(@customerId INT)
RETURNS DECIMAL(10, 2)
AS
BEGIN
    DECLARE @totalAmount DECIMAL(10, 2);
    
    SELECT @totalAmount = SUM(totalAmount)
    FROM orderss
    WHERE customerId = @customerId;

    RETURN @totalAmount;
END;

SELECT dbo.GetTotalOrderAmountByCustomer(2) AS TotalAmount;

select * from orderss;
