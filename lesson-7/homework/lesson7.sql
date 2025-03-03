CREATE TABLE Customers (
    CustomerID INT PRIMARY KEY,
    CustomerName VARCHAR(100)
);

CREATE TABLE Orders (
    OrderID INT PRIMARY KEY,
    CustomerID INT,
    OrderDate DATE
);

CREATE TABLE OrderDetails (
    OrderDetailID INT PRIMARY KEY,
    OrderID INT FOREIGN KEY REFERENCES Orders(OrderID),
    ProductID INT,
    Quantity INT,
    Price DECIMAL(10,2)
);

CREATE TABLE Products (
    ProductID INT PRIMARY KEY,
    ProductName VARCHAR(100),
    Category VARCHAR(50)
);

-- Insert Customers
INSERT INTO Customers (CustomerID, CustomerName) VALUES
(1, 'Alice Johnson'),
(2, 'Bob Smith'),
(3, 'Charlie Brown'),
(4, 'David Lee'),
(5, 'Emma Wilson');

-- Insert Products
INSERT INTO Products (ProductID, ProductName, Category) VALUES
(1, 'Laptop', 'Electronics'),
(2, 'Keyboard', 'Electronics'),
(3, 'Notebook', 'Stationery'),
(4, 'Pen', 'Stationery'),
(5, 'Phone', 'Electronics');

-- Insert Orders
INSERT INTO Orders (OrderID, CustomerID, OrderDate) VALUES
(101, 1, '2024-02-20'),
(102, 2, '2024-02-21'),
(103, 2, '2024-02-22'),
(104, 3, '2024-02-23'),
(105, 4, '2024-02-24');

-- Insert OrderDetails
INSERT INTO OrderDetails (OrderDetailID, OrderID, ProductID, Quantity, Price) VALUES
(1001, 101, 1, 1, 1200.00), -- Alice ordered a Laptop
(1002, 102, 2, 2, 50.00),   -- Bob ordered 2 Keyboards
(1003, 102, 3, 3, 5.00),    -- Bob ordered 3 Notebooks
(1004, 103, 1, 1, 1200.00), -- Bob ordered another Laptop
(1005, 104, 4, 5, 2.00),    -- Charlie ordered 5 Pens
(1006, 105, 5, 1, 800.00);  -- David ordered a Phone

select * from Customers;
select * from Orders;
select * from Products;
select * from OrderDetails;

/* Task 1. Retrieve All Customers With Their Orders (Include Customers Without Orders)
		Use an appropriate JOIN to list all customers, their order IDs, and order dates.
		Ensure that customers with no orders still appear. 
*/
select Customers.CustomerID, Customers.CustomerName, Orders.OrderID, Orders.OrderDate 
from customers
left join orders
on Customers.CustomerID = Orders.CustomerID


/* Task 2. Find Customers Who Have Never Placed an Order
		Return customers who have no orders.
*/
select *
from Customers
left join Orders
on Customers.CustomerID = Orders.CustomerID
where Orders.OrderID is null


/* Task 3.  List All Orders With Their Products
		Show each order with its product names and quantity.
*/
select o.OrderID, p.ProductName, od.Quantity, p.Category
from Orders o
join OrderDetails od on o.OrderID = od.OrderID
join Products p on od.ProductID = p.ProductID


/* Task 4. Find Customers With More Than One Order
		List customers who have placed more than one order.
*/
select c.CustomerID, c.CustomerName
from Customers c
join Orders o
on c.CustomerID = o.CustomerID
group by c.CustomerID, c.CustomerName
having count(o.OrderID) > 1;


/* Task 5. Find the Most Expensive Product in Each Order
*/
select OrderID, ProductName, Price
from (select o.OrderID, p.ProductName, od.Price,
		rank() over(partition by o.OrderID order by od.Price desc) as rnk
	from Orders o
	join OrderDetails od on o.OrderID = od.OrderID
	join Products p on od.ProductID = p.ProductID) as ranked
where rnk = 1


/* Task 6. Find the Latest Order for Each Customer
*/
select CustomerID, OrderID, OrderDate
from (
	select CustomerID, OrderID, OrderDate,
		rank() over(partition by CustomerID order by OrderDate desc) as rnk
	from Orders
) ranked
where rnk = 1


/* Task 7. Find Customers Who Ordered Only 'Electronics' Products
		List customers who only purchased items from the 'Electronics' category.
*/
select c.CustomerID, c.CustomerName
from Customers c
join Orders o on c.CustomerID = o.CustomerID
join OrderDetails od on od.OrderID = o.OrderID
join Products p on p.ProductID = od.ProductID
group by c.CustomerID, c.CustomerName
having count(distinct p.Category) = 1


/* Task 8.  Find Customers Who Ordered at Least One 'Stationery' Product
		List customers who have purchased at least one product from the 'Stationery' category.
*/
select distinct c.CustomerID, c.CustomerName
from Customers c
join Orders o on c.CustomerID = o.CustomerID
join OrderDetails od on od.OrderID = o.OrderID
join Products p on p.ProductID = od.ProductID
where p.Category = 'Stationery'


/* Task 9.  Find Total Amount Spent by Each Customer
		Show CustomerID, CustomerName, and TotalSpent.
*/
select c.CustomerID, c.CustomerName,
	sum(od.Price * od.Quantity) as TotalSpent
from Customers c
join Orders o on c.CustomerID = o.CustomerID
join OrderDetails od on o.OrderID = od.OrderID
group by c.CustomerID, c.CustomerName





