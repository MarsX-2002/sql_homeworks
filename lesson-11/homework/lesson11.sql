-- task 1
-- Step 1: Create a temporary table
DROP TABLE IF EXISTS #EmployeeTransfers;
CREATE TABLE #EmployeeTransfers (
    EmployeeID INT,
    Name VARCHAR(100),
    Department VARCHAR(50),
    Salary INT
);

-- Step 2: Insert rotated departments into the temporary table
INSERT INTO #EmployeeTransfers
SELECT 
    EmployeeID,
    Name,
    CASE 
        WHEN Department = 'HR' THEN 'IT'
        WHEN Department = 'IT' THEN 'Sales'
        WHEN Department = 'Sales' THEN 'HR'
    END AS Department,
    Salary
FROM Employees;

-- Step 3: Retrieve results
SELECT * FROM #EmployeeTransfers;


-- task 2
-- Step 1: Declare table variable
DECLARE @MissingOrders TABLE (
    OrderID INT,
    CustomerName VARCHAR(100),
    Product VARCHAR(100),
    Quantity INT
);

-- Step 2: Insert missing records
INSERT INTO @MissingOrders
SELECT *
FROM Orders_DB1
WHERE OrderID NOT IN (
    SELECT OrderID FROM Orders_DB2
);

-- Step 3: Retrieve missing orders
SELECT * FROM @MissingOrders;


-- task 3
-- Step 1: Create the view
CREATE VIEW vw_MonthlyWorkSummary AS
WITH EmployeeSummary AS (
    SELECT 
        EmployeeID,
        EmployeeName,
        Department,
        SUM(HoursWorked) AS TotalHoursWorked
    FROM WorkLog
    GROUP BY EmployeeID, EmployeeName, Department
),
DepartmentSummary AS (
    SELECT 
        Department,
        SUM(HoursWorked) AS TotalHoursDepartment,
        AVG(HoursWorked * 1.0) AS AvgHoursDepartment
    FROM WorkLog
    GROUP BY Department
)
SELECT 
    ES.EmployeeID,
    ES.EmployeeName,
    ES.Department,
    ES.TotalHoursWorked,
    DS.TotalHoursDepartment,
    DS.AvgHoursDepartment
FROM EmployeeSummary ES
JOIN DepartmentSummary DS
    ON ES.Department = DS.Department;
