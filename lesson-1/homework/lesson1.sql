/* Task 1 */
drop table if exists student;
create table student
(
	id int,
	name varchar(50), 
	age int
);

alter table student
alter column id int not null;

insert into student(id, name, age)
values
	(1, 'John', 23),
	(2, 'Johnny', 29)
	
select * from student;	

/* Task 2 */
drop table if exists product;
create table product
(
	product_id int unique,
	product_name varchar(50),
	price decimal
);

insert into product(product_id, product_name, price)
values
	(1, 'Apple', 10.0),
	(2, 'Orange', 22.0)

insert into product(product_id, product_name, price)
values
	(8, 'Grapes', 11.0),
	(9, 'Grapes', 11.0);

select * from product;	

alter table product
drop constraint UQ__product__47027DF47F7B53FE;

alter table product
add constraint UC_product_id unique (product_id);
-- Violation of UNIQUE KEY constraint 'UC_product_id'. Cannot insert duplicate key in object 'dbo.product'. The duplicate key value is (1).

alter table product
add constraint UC_product_id_name unique (product_id, product_name);
-- ??? Violation of UNIQUE KEY constraint 'UQ__product__B5B7DB51F1C83A24'. Cannot insert duplicate key in object 'dbo.product'. The duplicate key value is (1, Apple).

/* Task 3 Primary key */
drop table if exists orders;
create table orders
(
	order_id int primary key,
	customer_name varchar(50),
	order_date date
);

insert into orders(order_id, customer_name)
values
	(1, 'John')
-- Violation of PRIMARY KEY constraint 'PK__orders__46596229E1282252'. Cannot insert duplicate key in object 'dbo.orders'. The duplicate key value is (1).

alter table orders
drop constraint PK__orders__46596229E1282252;

alter table orders
add constraint PK__orders__id primary key (order_id);
-- Violation of PRIMARY KEY constraint 'PK__orders__id'. Cannot insert duplicate key in object 'dbo.orders'. The duplicate key value is (1).

select * from orders;	


/* Task 4 Foreign key */
drop table if exists category;
create table category
(
	category_id int primary key,
	category_name varchar(50)
);

drop table if exists item;
create table item
(
	item_id int primary key,
	item_name varchar(50),
	category_id int,
	constraint fk_category foreign key (category_id) references  category(category_id)
);

alter table item
drop constraint fk_category;

alter table item
add constraint fk_category foreign key (category_id) references category(category_id);

insert into category (category_id, category_name)
values
	(1, 'Technology')
	
select * from category;

insert into item (item_id, item_name, category_id)
values
	(2, 'Phone', 1)
	
select * from item;

/* Task 5 check constraint */
drop table if exists account;
create table account
(
	account_id int primary key,
	balance decimal(10, 2),
	account_type varchar(50), 
	constraint chk_balance check (balance >= 0),
	constraint chk_account_type check (account_type in ('Saving', 'Checking')) 
)


insert into account (account_id, balance, account_type)
values
	(3, -3.00, 'Smth')

alter table account
drop constraint chk_balance;

alter table account
drop constraint chk_account_type;

alter table account
add constraint chk_balance check (balance >= 0);

alter table account
add constraint chk_account_type check (account_type in ('Saving', 'Checking')); 

/* Task 6 default constraint */
drop table if exists customer;
create table customer
(
	customer_id int primary key,
	name varchar(50),
	city varchar(50) constraint df_city default 'Unknown'
);

alter table customer
drop constraint df_city;

alter table customer
add constraint df_city default 'Unknown' for city;

insert into customer(customer_id, name) 
select 1, 'John'

select * from customer;

/* Task 7 identity column */
drop table if exists invoice;
create table invoice
(
	invoice_id int primary key identity,
	amount decimal(10, 2),
);

insert into invoice (amount)
select 12.00

set identity_insert invoice on;

insert into invoice (invoice_id, amount)
select 100, 15.00

set identity_insert invoice off;

select * from invoice;

/* Task 8 all at once */
drop table if exists books;
create table books
(
	book_id int primary key identity,
	title varchar(250) constraint chk_title check (title != ''),
	price decimal(10, 2) constraint chk_price check (price > 0),
	genre varchar(50) constraint df_genre default 'Unknown' 
);


insert into books (title, price)
select 'Harry Potter', 13.00

select * from books;


/* Task 9 library management system */
/* drop in correct order to avoid FK dependency error */
drop table if exists loan;
drop table if exists member;
drop table if exists book;

/* create book table */
create table book(
	book_id int primary key identity,
	title varchar(250),
	author varchar(100),
	published_year int 
);

/* create member table */
create table member(
	member_id int primary key identity,
	name varchar(100),
	email varchar(100),
	phone_number varchar(100) 
);

/* create loan table with foreign keys */
create table loan(
	loan_id int primary key identity,
	book_id int,
	member_id int,
	loan_date date not null, 
	return_date date null,
	constraint fk_book foreign key (book_id) references book(book_id),
	constraint fk_member foreign key (member_id) references member(member_id),
);

/* insert data into book table */
insert into book (title, author, published_year) values
	('Harry Potter', 'JK Rowling', '2004'),
	('Book2', 'Someone', '2000') 

/* insert data into member table */
insert into member (name, email, phone_number) values
	('John Doe', 'example@gmail.com', '901234567'),
	('Anna Kim', 'example2@gmail.com', '999876543') 

/* insert data into loan table */
insert into loan (book_id, member_id, loan_date, return_date) values
	(1, 2, '2025-02-14', null),
	(2, 1, '2025-02-13', '2025-02-17')  

/* select data to verify */
select * from book;
select * from member;
select * from loan;



