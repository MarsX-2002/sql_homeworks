/*
Employees:
    - EmployeeID    INT
    - Name          VARCHAR(50)
    - Department    VARCHAR(50)
    - Salary        DECIMAL(10,2)
    - HireDate      DATE
*/
drop table if exists Employees;
create table Employees (
	EmployeeID int primary key,
	Name varchar(50),
	Department varchar(50),
	Salary Decimal(10, 2),
	HireDate Date
);

INSERT INTO Employees (EmployeeID, Name, Department, Salary, HireDate) VALUES
(1, 'Alice Johnson', 'HR', 50000.00, '2020-01-15'),
(2, 'Bob Smith', 'IT', 60000.00, '2019-03-22'),
(3, 'Carol Williams', 'Finance', 70000.00, '2021-06-10'),
(4, 'David Brown', 'HR', 50000.00, '2021-07-01'),  -- Same salary as Alice
(5, 'Eve Davis', 'IT', 80000.00, '2022-08-18'),
(6, 'Frank Miller', 'Finance', 70000.00, '2023-09-25'), -- Same salary as Carol
(7, 'Grace Wilson', 'IT', 60000.00, '2020-11-30'), -- Same salary as Bob
(8, 'Henry Moore', 'Sales', 90000.00, '2021-12-12'),
(9, 'Ivy Taylor', 'Sales', 90000.00, '2020-10-05'), -- Same salary as Henry
(10, 'Jack Anderson', 'HR', 55000.00, '2018-02-17'); -- Same department as Alice & David


select *
from Employees;

/* Task 1. Assign a Unique Rank to Each Employee Based on Salary */
select *,
	row_number() over(order by salary desc) as rns
from Employees
order by salary desc

/* Task 2. Find Employees Who Have the Same Salary Rank */
select *,
	dense_rank() over(order by salary desc) as SalaryRank
from Employees
order by SalaryRank

/* Task 3. Identify the Top 2 Highest Salaries in Each Department */
select *
from (
	select *,
		dense_rank() over(partition by department order by salary desc) as SalaryDepRank
	from Employees
) as RankedSalaries
where SalaryDepRank <= 2

/* Task 4. Find the Lowest-Paid Employee in Each Department */
select *
from
(select *,
	row_number() over(partition by department order by salary) as MinSalDep
from Employees) as RankedMinSalary
where MinSalDep = 1
order by Department

/* Task 5. Calculate the Running Total of Salaries in Each Department */
select *,
	sum(Salary) over(partition by department order by employeeid rows between unbounded preceding and current row) as RunningTotal	
from Employees












