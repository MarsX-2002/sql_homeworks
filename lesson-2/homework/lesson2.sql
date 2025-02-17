use lesson2;

/* 1. DELETE vs TRUNCATE vs DROP (with IDENTITY example) */
drop table if exists test_identity;
create table test_identity (
	id int primary key identity(1, 1),
	description varchar(50)
);

insert into test_identity (description) values
	('First row'),
	('Second row'),
	('Third row'),
	('Fifth row'),
	('Sixth row')

-- DELETE (condition)
delete from test_identity where id=3;
-- TRUNCATE (clear whole table)
truncate table test_identity;
-- DROP (remove table)
drop table test_identity;
	
-- select * from test_identity;

/* 
i. What happens to the identity column when you use DELETE?
ii. What happens to the identity column when you use TRUNCATE?
iii. What happens to the table when you use DROP? 

i. if used with condition (for example where id=3) only deletes that row, by default clears whole table and id keeps incrementing
ii. same as delete clears whole table, but also resets identity to 1
iii. deletes entiry table, no longer accessible
*/

/* 2. common data types */
drop table if exists data_types_demo;
create table data_types_demo (
	id int primary key,
	uid uniqueidentifier,
	name varchar(50),
	price decimal(10, 2),
	price2 float,
	description varchar(max),
	birth_date	date,
	exam_time time, 
	created_datetime datetime,
);

insert into data_types_demo (id, uid, name, price, price2, description, birth_date, exam_time, created_datetime) values
	(1, newid(), 'John', 12.34, 12.3456, 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.', '2001-01-23', '11:00', GETDATE())

select * from data_types_demo;
-- 1	FC44FE78-1765-44A1-B35D-CFDD43250F92	John	12.34	12.3456	Lorem ipsum dolor sit amet, consectetur adipiscing elit.	2001-01-23	11:00:00.0000000	2025-02-17 10:13:03.747

/* 3. insert and retrieve image */
drop table if exists photos;
create table photos (
	id int primary key,
	photo_name varchar(250),
	photo_data varbinary(max)
);

insert into photos (id, photo_name, photo_data)
select 1, 'example_img', BulkColumn from openrowset(
	bulk 'C:\Users\ljack\Desktop\maab uz ai\sql_homeworks\lesson-2\homework\images\apple.jpg', SINGLE_BLOB
) as img;

select * from photos;

SELECT @@SERVERNAME;

/* 4. computed columns */
drop table if exists student;
create table student (
	id int primary key identity,
	class_name varchar(50),
	classes int, 
	tuition_per_class decimal(10, 2),
	total_tuition as (classes * tuition_per_class) persisted
);
insert into student (class_name, classes, tuition_per_class) values
	('Math', 10, 10.00),
	('Python', 8, 10.00),
	('SQL', 5, 12.00)

select * from student;

/* 5. csv to sql server */
drop table if exists worker;
create table worker (
	id int primary key,
	name varchar(50)
);

bulk insert worker
from 'C:\Users\ljack\Desktop\maab uz ai\sql_homeworks\lesson-2\homework\data\worker.csv'
with (
	firstrow=2,
	fieldterminator=',',
	rowterminator='\n'
);

select * from worker;







