/* DDL */
-- Create Employees Table
CREATE TABLE Employees (
    EmployeeID INT PRIMARY KEY,
    Name VARCHAR(100) NOT NULL,
    DepartmentID INT NULL,
    Salary DECIMAL(10,2) NOT NULL
);

-- Create Departments Table
CREATE TABLE Departments (
    DepartmentID INT PRIMARY KEY,
    DepartmentName VARCHAR(100) NOT NULL
);

-- Create Projects Table
CREATE TABLE Projects (
    ProjectID INT PRIMARY KEY,
    ProjectName VARCHAR(100) NOT NULL,
    EmployeeID INT NULL
);

-- Adding Foreign Keys
ALTER TABLE Employees 
ADD CONSTRAINT FK_Employees_Departments 
FOREIGN KEY (DepartmentID) REFERENCES Departments(DepartmentID);

ALTER TABLE Projects 
ADD CONSTRAINT FK_Projects_Employees 
FOREIGN KEY (EmployeeID) REFERENCES Employees(EmployeeID);

-- Insert Data into Departments
INSERT INTO Departments (DepartmentID, DepartmentName) VALUES
(101, 'IT'),
(102, 'HR'),
(103, 'Finance'),
(104, 'Marketing');

-- Insert Data into Employees
INSERT INTO Employees (EmployeeID, Name, DepartmentID, Salary) VALUES
(1, 'Alice', 101, 60000),
(2, 'Bob', 102, 70000),
(3, 'Charlie', 101, 65000),
(4, 'David', 103, 72000),
(5, 'Eva', NULL, 68000);  -- Eva has no department

-- Insert Data into Projects
INSERT INTO Projects (ProjectID, ProjectName, EmployeeID) VALUES
(1, 'Alpha', 1),
(2, 'Beta', 2),
(3, 'Gamma', 1),
(4, 'Delta', 4),
(5, 'Omega', NULL);  -- Omega project has no assigned employee

select * from Departments; 
select * from Employees; 
select * from Projects; 
/* 
1. **INNER JOIN**  
   - Write a query to get a list of employees along with their department names.  

2. **LEFT JOIN**  
   - Write a query to list all employees, including those who are not assigned to any department.  

3. **RIGHT JOIN**  
   - Write a query to list all departments, including those without employees.  

4. **FULL OUTER JOIN**  
   - Write a query to retrieve all employees and all departments, even if there’s no match between them.   

5. **JOIN with Aggregation**  
   - Write a query to find the total salary expense for each department.  

6. **CROSS JOIN**  
   - Write a query to generate all possible combinations of departments and projects.  

7. **MULTIPLE JOINS**  
   - Write a query to get a list of employees with their department names and assigned project names. Include employees even if they don’t have a project.  

*/

/* 1. **INNER JOIN**  
   - Write a query to get a list of employees along with their department names. 
*/
select e.EmployeeID, e.Name, d.DepartmentName
from Employees e
join Departments d on e.DepartmentID = d.DepartmentID


/* 2. **LEFT JOIN**  
   - Write a query to list all employees, including those who are not assigned to any department. 
*/
select e.EmployeeID, e.Name, d.DepartmentName
from Employees e
left join Departments d on e.DepartmentID = d.DepartmentID


/* 3. **RIGHT JOIN**  
   - Write a query to list all departments, including those without employees.  
*/
select e.EmployeeID, e.Name, d.DepartmentName
from Employees e
right join Departments d on e.DepartmentID = d.DepartmentID


/* 4. **FULL OUTER JOIN**  
   - Write a query to retrieve all employees and all departments, even if there’s no match between them.
*/
select e.EmployeeID, e.Name, d.DepartmentName
from Employees e
full outer join Departments d on e.DepartmentID = d.DepartmentID


/* 5. **JOIN with Aggregation**  
   - Write a query to find the total salary expense for each department. 
*/
select d.DepartmentID, d.DepartmentName,
	sum(Salary) as SalaryPerDep
from Employees e
right join Departments d on e.DepartmentID = d.DepartmentID
group by d.DepartmentID, d.DepartmentName


/* 6. **CROSS JOIN**  
   - Write a query to generate all possible combinations of departments and projects.  
*/
select *
from Departments
cross join Projects 


/* 7. **MULTIPLE JOINS**  
   - Write a query to get a list of employees with their department names and assigned project names. Include employees even if they don’t have a project.   
*/
select e.EmployeeID, e.Name, d.DepartmentName, p.ProjectName
from Employees e
left join Departments d on d.DepartmentID = e.DepartmentID
left join Projects p on e.EmployeeID = p.EmployeeID



