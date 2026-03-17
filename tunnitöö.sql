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

-- All salaries
select sum(employees.salary) as total_salaries from Employees;

-- Employee with min salary
select min(Employees.salary), Employees.name from Employees
group by Employees.name fetch first 1 row only;

-- 17.03.26

-- Left join
select Departments.location, sum(cast(Salary as int)) as TotalSalary
from Employees
left join Departments
on Employees.department_id = Departments.id
group by Departments.location;

-- Uus veerg City Employees tabelisse
alter table Employees add city nchar(30);

select * from Employees;

update Employees set city = 'New York' where id = 1;
update Employees set city = 'London' where id = 2;
update Employees set city = 'London' where id = 3;
update Employees set city = 'Boston' where id = 4;
update Employees set city = 'New York' where id = 5;
update Employees set city = 'Boston' where id = 6;
update Employees set city = 'New York' where id = 7;
update Employees set city = 'London' where id = 8;
update Employees set city = 'London' where id = 9;
update Employees set city = 'Boston' where id = 10;

select city, gender, sum(cast(employees.salary as int)) as TotalSalary
from Employees group by city, gender;

-- Sama command, aga linnad on tähestikulises järjekorras
select city, gender, sum(cast(employees.salary as int)) as TotalSalary
from Employees group by city, gender order by city;

select city,
       gender,
       sum(cast(employees.salary as int)) as TotalSalary,
       count(*) as totalEmployees
from Employees group by city, gender
order by city;

-- Ainult kõik mehed linnade kaupa
select city,
       count(*) as totalMaleEmployees,
       sum(cast(employees.salary as int)) as TotalMensSalary
from Employees where gender = 'Male'
group by city
order by city;

-- Sama asi "having" võtmesõnaga
select city,
       count(*) as totalMaleEmployees,
       sum(cast(employees.salary as int)) as TotalMensSalary
from Employees
group by city, gender
having Employees.gender = 'Male'
order by city;

--Filter by salary (>4000)
select name, salary as salaryAbove4000
from Employees where Employees.salary > 4000
group by name, Employees.salary
order by Employees.salary;

alter table Employees drop column city;

-- Inner join
-- Kuvab nimed, kellel on DepartmentId all väärtus
select e.name, gender, salary, d.name
from Employees as e
inner join Departments as d
on e.department_id = d.id;

-- Left join Employees tabel, DepartmentName kuvab ainult olemasolul
select e.name, salary, d.name from Employees as e
left join Departments as d
on e.department_id = d.id;

-- Sama, aga right join
select e.name, salary, d.name from Employees as e
right join Departments as d
on e.department_id = d.id; -- Delhi all pole töötajaid, tabelis seda kuvatakse "null" reana e tabelis

--cross join
select e.name, gender, salary, d.name
from Employees as e
cross join Departments as d;

-- inner join
select e.name, gender, salary, d.name
from Employees as e
inner join Departments as d
on d.id = e.department_id;

insert into Employees values (11, 'Ben', 'Ten', 3500, NULL);
insert into Employees values (NULL, NULL, NULL, NULL, NULL);
select * from Employees;

-- Ainult need isikud, kellel on departmentName Null
select e.name, gender, salary, d.name from Employees as e
         left join Departments as d
         on e.department_id = d.id
         where department_id IS NULL;

select e.name, salary, d.name from Employees as e
    right join Departments as d
    on e.department_id = d.id
    where e.department_id IS NULL;

-- Full join
-- Kui on vaja kuvada kõik read mõlemast tabelist, millel ei ole vastet
select e.name, salary, d.name from Employees as e
    full join Departments as d
    on e.department_id = d.id
    where e.department_id IS NULL;

-- Changing table name
-- execute sp_rename 'Employees1', 'Employees'; (MS SQL exclusive)

alter table Employees add manager_id int;

-- select e.name as Employee, m.name as Manager
--     from Employees as e
--     left join Departments d
--     on e.manager_id = ;
--
-- select e.name as Employee, m.name as Manager
--     from Employees as e
--     inner join Employees m
--     on e.manager_id = m.id;