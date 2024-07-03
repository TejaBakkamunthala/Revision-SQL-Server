USE SUBQUERIES

--Write a query retrieves the customer name, order date, and total amount 
--from the "orders" table for orders with a total amount greater than the average total 
--amount of orders placed in the year 2022.


CREATE TABLE customers (
    customerId INT PRIMARY KEY IDENTITY(1,1),
    customerName VARCHAR(30)
);

INSERT INTO customers (customerName)
VALUES
    ('Virat Kohli'),
    ('Rohith Sharma'),
    ('Suresh Raina');


	CREATE TABLE orders (
    orderId INT PRIMARY KEY IDENTITY(1,1),
    customerId INT FOREIGN KEY REFERENCES customers(CustomerId),
    orderDate DATE,
    totalAmount INT
);


INSERT INTO orders (customerId, orderDate, totalAmount)
VALUES
    ( 1, '2022-03-15', 100),
    ( 2, '2022-04-22', 8000),
    ( 3, '2022-05-10', 2000),
    ( 1, '2023-01-05', 100),
    ( 2, '2023-02-20', 925),
    ( 3, '2023-03-18', 18075),
    (1, '2023-04-30', 150);


	SELECT c.customerName, o.orderDate, o.totalAmount
FROM orders o
JOIN customers c ON o.customerId = c.customerId
WHERE o.totalAmount > (
    SELECT AVG(totalAmount)
    FROM orders
    WHERE YEAR(orderDate) = 2022
);



--2.Write a query retrieves the product name and price from the "products" table for products that have
--  been ordered by a specific customer with the ID 123.

CREATE TABLE products (
    productId INT PRIMARY KEY IDENTITY(1,1),
    productName VARCHAR(30),
    price DECIMAL(10, 2)
);

INSERT INTO products (productName, price) VALUES
('Laptop', 30000.00),
('Smartphone', 10000.00),
('Charger', 600.00);

SELECT * FROM PRODUCTS;

CREATE TABLE orders2 (
    orderId INT PRIMARY KEY IDENTITY(1,1),
    customerId INT FOREIGN KEY REFERENCES Customers(CustomerId),
    productId INT FOREIGN KEY REFERENCES Products(ProductId),
    orderDate DATE,
);


INSERT INTO orders2 ( customerId, productId, orderDate) VALUES
( 1, 1, '2023-06-01'),
( 1, 3, '2023-06-15'),
( 2, 2, '2023-06-20'),
( 2, 2, '2023-06-20');

SELECT * FROM ORDERS2;

select * from customers;

SELECT productName, price
FROM products
WHERE productId IN (
    SELECT productId
    FROM orders2
    WHERE customerId = 1
);



--3.query retrieves the employee name and hire date from the "employees" table for employees
--who were hired most recently in their respective departments.

CREATE TABLE departments (
    departmentId INT PRIMARY KEY identity(1,1) ,
    departmentName VARCHAR(30)
);

INSERT INTO departments ( departmentName) VALUES
( 'IT'),
( 'DEVELOPER'),
( 'HR'),
('TESTER');

SELECT *FROM departments;

CREATE TABLE employees (
    employeeId INT PRIMARY KEY IDENTITY(1,1),
    employeeName VARCHAR(20),
    hireDate DATE,
    departmentId INT FOREIGN KEY REFERENCES departments(departmentId)
);

INSERT INTO employees (employeeName, hireDate, departmentId) VALUES
( 'Virat', '2022-01-15', 1),
( 'Rohith', '2023-03-20', 1),
( 'Raina', '2021-07-10', 2),
( 'Dhoni', '2023-06-01', 2),
( 'Bumrah', '2023-09-25', 3),
( 'Siraj', '2023-09-14', 3);


SELECT employeeName, hireDate
FROM employees
WHERE hireDate = (
    SELECT MAX(hireDate)
    FROM employees AS e
    WHERE e.departmentId = employees.departmentId
);

SELECT employeeName, hireDate
FROM employees
WHERE hireDate = (
    SELECT MIN(hireDate)
    FROM employees AS e
    WHERE e.departmentId = employees.departmentId
);

--4.query retrieves the customer names from the "customers" table for 
--\customers who have placed an order on a specific date, in this case, May 1, 2023.

SELECT * FROM CUSTOMERS;

SELECT * FROM ORDERS;


SELECT customerId,customerName
FROM customers
WHERE customerId IN (
    SELECT customerId
    FROM orders
    WHERE orderDate = '2023-02-20'
);


--5.query retrieves the customer name from the "customers" table along with the count of orders 
--made by each customer. The subquery is used within the SELECT statement to calculate the order count
--for each customer.


SELECT 
    CustomerId,customerName,
    (SELECT COUNT(*) 
     FROM orders o
     WHERE o.customerId = customers.customerId) AS order_count
FROM customers;

--6.query calculates the total number of orders for each product in the "order_details" 
--table and then retrieves the product name along with the total_orders. The subquery is 
--used in the FROM clause to generate a temporary result set that is then joined with the "products" table.


CREATE TABLE orderDetails (
    orderId INT PRIMARY KEY IDENTITY(1,1),
    productId INT FOREIGN KEY REFERENCES Products(ProductId),
    quantity INT,
);

select *from products;

INSERT INTO orderDetails ( productId, quantity) VALUES
( 1, 2),
( 2, 1),
( 1, 1),
( 3, 4),
( 2, 4),
( 3, 4),
( 2, 4),
( 3, 4);


SELECT 
    p.productName,
    od.totalOrders
FROM 
    products p
JOIN 
    (SELECT 
        productId, 
        COUNT(*) AS totalOrders
     FROM 
        orderDetails
     GROUP BY 
        productId) od
ON 
    p.productId = od.productId;


--7. query retrieves the employee name and salary from the "employees" table for employees
--whose salary is greater than the average salary of employees in the department with ID 100. 
--The subquery is used in the WHERE clause to compare the salary of each employee with the average salary.


SELECT * FROM departments;

CREATE TABLE employees7 (
    employeeId INT PRIMARY KEY IDENTITY(1,1),
    employeeName VARCHAR(30),
    salary DECIMAL(10, 2),
    departmentId INT FOREIGN KEY REFERENCES departments(departmentId)
);

INSERT INTO employees7 ( employeeName, salary, departmentId) VALUES
( 'Rohith', 750000, 1),
( 'Virat', 500, 1),
( 'Dhoni', 60000, 2),
( 'Raina', 55000, 2),
( 'Siraj', 65000, 3),
( 'Bumrah', 75000, 3),
( 'Axar', 500, 1),
( 'Kuldeep', 60000, 2),
( 'Chahal', 55000, 2),
( 'Dube', 650000, 4),
( 'Hradik', 6500, 4);


SELECT 
    employeeName, 
    salary
FROM 
    employees7
WHERE 
    salary > (
        SELECT 
            AVG(salary) 
        FROM 
            employees7 
        WHERE 
            departmentId = 4
    )
AND 
    departmentId = 4;

--8.query deletes rows from the "customers" table where there exists an order in the "orders" table for that 
--customer with an order date earlier than January 1, 2023. The subquery with EXISTS is used in the
--WHERE clause to check for the existence of such orders.

SELECT * FROM customers;
SELECT *FROM ORDERS;

--DELETE FROM customers 
--WHERE EXISTS (
--    SELECT 1  
--    FROM orders o
--    WHERE o.customerId = customers.customerId 
--    AND O.orderdate < '2023-04-22'
--);

DELETE FROM orders
WHERE EXISTS (
    SELECT 1 
    FROM customers
    WHERE orders.customerId = customers.customerId 
    AND orders.orderDate < '2022-04-22'
);

select * from orders;


--8.query deletes rows from the "customers" table where there exists an order in the "orders" table for that 
--customer with an order date earlier than January 1, 2023. The subquery with EXISTS is used in the
--WHERE clause to check for the existence of such orders.

CREATE TABLE customers8 (
    customerId INT PRIMARY KEY IDENTITY(1,1),
    customerName VARCHAR(30)
);

INSERT INTO customers8 ( customerName) VALUES
( 'Virat Kohli'),
( 'Rohith Sharma '),
( 'Rahul '),
('Samson'),
('Pant');


select *from customers8;

CREATE TABLE orders8 (
    orderId INT PRIMARY KEY IDENTITY(1,1),
    customerId INT,
    orderDate DATE,
);

INSERT INTO orders8 (customerId, orderDate)
VALUES
    ( 1, '2022-03-15'),
    ( 2, '2022-04-22'),
    ( 3, '2022-05-10'),
    ( 1, '2023-01-05'),
    ( 2, '2023-02-20'),
    ( 3, '2023-03-18'),
    ( 1, '2024-01-05'),
    ( 2, '2024-02-20'),
    ( 3, '2023-03-18'),
	(4, '2021-01-01');

	select * from orders8;

	DELETE FROM customers8
    WHERE EXISTS (
    SELECT 1 
    FROM orders8
    WHERE orders8.customerId = customers8.customerId 
    AND orders8.orderDate <= '2021-01-01'
);

SELECT *FROM customers8;

