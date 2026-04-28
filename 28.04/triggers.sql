-- Triggerid
-- Tüübid: DML, DDL, LOGON

-- Trigger on stored procedure eriliik, mis käivitub automaatselt, kui andmebaasis toimub mingi tegevus.

-- DML - Data Manipulation Language
-- Põhikäsklused insert, update, delete
-- Saab jaotada:
-- 1. After Trigger - käivitub peale sündmust , kui kuskil on tehtud insert, update, delete
-- 2. Instead of Trigger

create table EmployeeAudit(
    Id int identity(1, 1) primary key,
    AuditData nvarchar(100)
);

create trigger trEmployeeForInsert
    on Employees
    for insert
    as begin
    declare @Id int
    select @Id = Id from inserted
        insert into EmployeeAudit
        values ('New employee with Id = ' + cast(@Id as nvarchar)
               + 'is added at ' + cast(getdate() as nvarchar) )
end