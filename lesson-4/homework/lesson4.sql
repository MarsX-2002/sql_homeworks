/*? Task 1 */
CREATE TABLE [dbo].[TestMultipleZero]
(
    [A] [int] NULL,
    [B] [int] NULL,
    [C] [int] NULL,
    [D] [int] NULL
);
GO

INSERT INTO [dbo].[TestMultipleZero](A,B,C,D)
VALUES 
    (0,0,0,1),
    (0,0,1,0),
    (0,1,0,0),
    (1,0,0,0),
    (0,0,0,0),
    (1,1,1,0);

-- 1st solution
select * 
from [dbo].[TestMultipleZero]
where A <> 0 or B <> 0 or C <> 0 or D <> 0;

-- 2nd solution
select * 
from [dbo].[TestMultipleZero] as t
where (
	select sum(vals)
	from (values (A), (B), (C), (D)) as temp(vals)
) > 0;


/*? Task 2 */
CREATE TABLE TestMax
(
    Year1 INT
    ,Max1 INT
    ,Max2 INT
    ,Max3 INT
);
GO
 
INSERT INTO TestMax 
VALUES
    (2001,10,101,87)
    ,(2002,103,19,88)
    ,(2003,21,23,89)
    ,(2004,27,28,91);

select 
	*,
	(select max(YearMax)
		from (values (Max1), (Max2), (Max3)) as MaxTempTable(YearMax))
	as FinalMax
from TestMax

/*+ Task 3 */
/* date between May 7 and May 15 */
CREATE TABLE EmpBirth
(
    EmpId INT  IDENTITY(1,1) 
    ,EmpName VARCHAR(50) 
    ,BirthDate DATETIME 
);
 
INSERT INTO EmpBirth(EmpName,BirthDate)
SELECT 'Pawan' , '12/04/1983'
UNION ALL
SELECT 'Zuzu' , '11/28/1986'
UNION ALL
SELECT 'Parveen', '05/07/1977'
UNION ALL
SELECT 'Mahesh', '01/13/1983'
UNION ALL
SELECT'Ramesh', '05/09/1983';

select *
from EmpBirth
where month(BirthDate) = 5 and day(BirthDate) between 7 and 15;

/*? Task 4 */
-- Order letters but 'b' must be first/last
-- Order letters but 'b' must be 3rd (Optional)

create table letters
(letter char(1));

insert into letters
values ('a'), ('a'), ('a'), 
  ('b'), ('c'), ('d'), ('e'), ('f');

/*
select 
	stuff(stuff(STRING_AGG(letter, '') within group (order by letter), 4, 1, null), 1, 0, 'b') as bfirst, -- b first
	stuff(STRING_AGG(letter, '') within group (order by letter), 4, 1, '') + 'b' as blast, -- b last
	stuff(stuff(STRING_AGG(letter, '') within group (order by letter), 4, 1, null), 3, 0, 'b') as bthird
from letters;
*/
-- bfirst
select letter as bfirst
from letters 
order by (
	case 
		when letter = 'b' then 1
		else 2
	end
)

-- blast
select letter as blast
from letters 
order by (
	case 
		when letter = 'b' then 2
		else 1
	end
)

-- bthird ?












