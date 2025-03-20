-- task 1: Given this Employee table below, find the level of depth each employee from the President.
WITH EmployeeHierarchy AS (
    -- Base case: President (Depth = 0)
    SELECT 
        EmployeeID,
        ManagerID,
        JobTitle,
        0 AS Depth
    FROM 
        Employees
    WHERE 
        ManagerID IS NULL
    
    UNION ALL
    
    -- Recursive case: Find the next level of employees
    SELECT 
        e.EmployeeID,
        e.ManagerID,
        e.JobTitle,
        eh.Depth + 1
    FROM 
        Employees e
    INNER JOIN 
        EmployeeHierarchy eh ON e.ManagerID = eh.EmployeeID
)

SELECT *
FROM EmployeeHierarchy
ORDER BY Depth, EmployeeID;

-- task 2: Find Factorials up to N
DECLARE @N INT = 10;

WITH Numbers AS (
    SELECT 
        ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS Num
    FROM 
        master.dbo.spt_values
)
SELECT 
    Num,
    CAST(EXP(SUM(LOG(Num)) OVER (ORDER BY Num)) AS BIGINT) AS Factorial
FROM 
    Numbers
WHERE 
    Num <= @N;

-- task 3: Find Fibonacci numbers up to N
DECLARE @N INT = 10;

WITH Fibonacci AS (
    SELECT 
        1 AS n, 
        1 AS Fibonacci_Number,
        0 AS Prev_Fibonacci

    UNION ALL

    SELECT 
        n + 1,
        Fibonacci_Number + Prev_Fibonacci,
        Fibonacci_Number
    FROM 
        Fibonacci
    WHERE 
        n < @N
)

SELECT n, Fibonacci_Number
FROM Fibonacci
ORDER BY n;







