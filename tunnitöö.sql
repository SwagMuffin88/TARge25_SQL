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
add constraint CK_Person_Age check (Age > 0 and Age < 155);

insert into Person values (10, 'Green Arrow', 'g@g.com', 2, 100);

delete from Person where id = 8;

alter table Person add city nchar(50);