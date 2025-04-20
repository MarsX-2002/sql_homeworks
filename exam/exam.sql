-- create database exam;
-- use exam;

CREATE TABLE NthHighest
(
 Name  varchar(5)  NOT NULL,
 Salary  int  NOT NULL
)
 
--Insert the values
INSERT INTO  NthHighest(Name, Salary)
VALUES
('e5', 45000),
('e3', 30000),
('e2', 49000),
('e4', 36600),
('e1', 58000)
 
--Check data
select top 1 name,  min(salary) Salary
from (SELECT top 2 Name,Salary 
FROM NthHighest
order by Salary desc) t 
group by name
order by salary;

-- task 2

CREATE TABLE TestMax
(
Year1 INT
,Max1 INT
,Max2 INT
,Max3 INT
)
GO
 
--Insert data
INSERT INTO TestMax 
VALUES
 (2001,10,101,87)
,(2002,103,19,88)
,(2003,21,23,89)
,(2004,27,28,91)
 
--Select data
Select Year1,Max1,Max2,Max3 FROM TestMax

select year1,
    (select max(val)
    from (values (Max1) , (Max2) , (Max3)) as values_table(val)) 
    as MaxValues
from TestMax


-- task 3
DROP TABLE IF EXISTS #Employees;
GO

CREATE TABLE #Employees
(
EmployeeID  INTEGER PRIMARY KEY,
ManagerID   INTEGER NULL,
JobTitle    VARCHAR(100) NOT NULL
);
GO

INSERT INTO #Employees (EmployeeID, ManagerID, JobTitle) VALUES
(1001,NULL,'President'),(2002,1001,'Director'),
(3003,1001,'Office Manager'),(4004,2002,'Engineer'),
(5005,2002,'Engineer'),(6006,2002,'Engineer');
GO



-----
select e.EmployeeID, e.ManagerID, e.JobTitle, isnull(he.depth, 0) as Depth
from #Employees e
cross apply
(
select count(*) as depth
from #Employees m
    where e.ManagerID is not null and (e.ManagerID = m.EmployeeID or m.ManagerID =
    (select ManagerID
    from #Employees
    where EmployeeID = e.ManagerID)
    )
) he 
order by depth, e.EmployeeID

-- task 2
DROP TABLE IF EXISTS #TestCases;
GO

CREATE TABLE #TestCases
(
TestCase  VARCHAR(1) PRIMARY KEY
);
GO

INSERT INTO #TestCases (TestCase) VALUES
('A'),('B'),('C');
GO

select *
from #TestCases


select t1.TestCase + ',' + t2.TestCase + ',' + t3.TestCase as res
from #TestCases t1
join #TestCases t2 on t2.TestCase <> t1.TestCase
join #TestCases t3 on t3.TestCase not in (t1.TestCase, t2.TestCase)
order by res

 

