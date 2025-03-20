-- task 1
select min(StepNumber) as [Min Step Number],
    max(StepNumber) as [Max Step Number],
    Status,
    count(*) as [Consecutive Count]

from (select *, 
    row_number() over(order by StepNumber) - 
        row_number() over(partition by Status order by StepNumber) as grp
from  Groupings) t
group by grp, Status
order by [Min Step Number]

-- task 2: Find all the year-based intervals from 1975 up to current when the company did not hire employees.
SELECT 
    CAST(MIN(Year) AS VARCHAR) + ' - ' + CAST(MAX(Year) AS VARCHAR) AS Years
FROM (
    -- Generate a list of years using a numbers table
    SELECT 
        1975 + n AS Year,
        1975 + n - ROW_NUMBER() OVER (ORDER BY n) AS grp
    FROM 
        (SELECT TOP (YEAR(GETDATE()) - 1975 + 1) 
            ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) - 1 AS n
         FROM 
            master.dbo.spt_values) AS Numbers
    LEFT JOIN 
        (SELECT DISTINCT YEAR(HIRE_DATE) AS HireYear FROM EMPLOYEES_N) h 
        ON 1975 + n = h.HireYear
    WHERE 
        h.HireYear IS NULL
) AS MissingYears
GROUP BY 
    grp
ORDER BY 
    MIN(Year);