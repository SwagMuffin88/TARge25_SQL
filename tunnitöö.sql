create database TARge25;

-- drop database TARge25;


create table Gender
(
Id int not null primary key,
Gender nchar(10) not null
);


insert into Gender (Id, Gender)
values (2, 'Male'),
(1, 'Female'),
(3, 'Unknown');

create table Person
(
    id int not null primary key,
    name nchar(30),
    email nchar(30),
    gender_id int
);

insert into Person (id, name, email, gender_id)
values (1, 'Superman', 's@s.com', 2),
(2, 'Wonderwoman', 'w@w.com', 1),
(3, 'Batman', 'b@b.com', 2),
(4, 'Aquaman', 'a@a.com', 2),
(5, 'Catwoman', 'cat@cat.com', 1),
(6, 'Antman', 'ant"ant.com', 2),
(8, null, null, 2);

select * from Person;

alter table Person add age int;

alter table Person
add constraint CK_Person_Age check (age > 0 and age < 155);

insert into Person values (10, 'Green Arrow', 'g@g.com', 2, 100);

update Person set age = 30 where id = 3;
update Person set age = 32 where id = 1;
update Person set age = 40 where id = 2;
update Person set age = 37 where id = 4;
update Person set age = 89 where id = 6;
update Person set age = 60 where id = 5;

update Person set city = 'Tallinn' where id = 5;
update Person set city = 'Tallinn' where id = 1;
update Person set city = 'Tallinn' where id = 2;

delete from Person where id = 8;

alter table Person add city nchar(50);

select * from Person order by name;

select * from Person order by name desc;

select * from Person fetch first 3 rows only;

select * from Person order by name fetch first 3 rows only;

select * from Person order by age fetch first 3 rows only;

select * from (
    select t.*, percent_rank() over(order by id) prn from Person t) t
        where prn <= 0.5;

select min(age) from Person;

select * from Person order by age desc fetch first 1 rows only;

select Person.city, sum(Person.age)  as TotalAge from Person group by city;

select count(*) from Person;

select count(*), sum(age), Person.city from Person where gender_id = 2 group by city;

select Person.gender_id, sum(age) as TotalAge, count(id) as TotalPersons
from Person where age > 41 group by Person.city, gender_id;

-- **********************************

create table Employees();
create table Departments();

alter table Departments add id int primary key;
alter table Departments add name nchar(50);
alter table Departments add location nchar(50);
alter table Departments add department_head nchar(50);

alter table Employees
    add id int,
    add name nchar(50),
    add gender nchar(30),
    add salary float,
    add department_id int;

select * from Employees;

insert into Departments
values (1, null, 'London', null),
       (2, null, 'New York', null),
       (3, null, 'Sydney', null);

insert into Departments
values (4, 'Payroll', 'Delhi', 'Christie');

update Departments set name = 'IT' where id = 1;
update Departments set name = 'HR' where id = 2;
update Departments set name = 'Other' where id = 3;

update Departments set department_head = 'Rick' where id = 1;
update Departments set department_head = 'Ron' where id = 2;
update Departments set department_head = 'Cinderella' where id = 3;

insert into Employees
values
        (1,'Tom', 'Male', 4000, 1), -- London
       (2, 'Pam', 'Female', 3000, 2), -- NY
       (3, 'John', 'Male', 3500, 1), -- London
       (4, 'Sam', 'Male', 4500, 1), -- London
       (5, 'Todd', 'Male', 2800, 3), -- Sydney
       (6, 'Ben', 'Male', 7000, 2), -- NY
       (7, 'Sara', 'Female', 4800, 3), -- Sydney
       (8, 'Valarie', 'Female', 5500, 2), -- NY
       (9, 'James', 'Male', 6500, 1),  -- London
       (10, 'Russell', 'Male', 8800, 1); -- London

select Employees.name, gender, salary, Departments.name
from Employees
    left join Departments
on Employees.department_id = Departments.id;

select sum(employees.salary) as total_salaries from Employees;

select min(Employees.salary), Employees.name from Employees
group by Employees.name fetch first 1 row only;