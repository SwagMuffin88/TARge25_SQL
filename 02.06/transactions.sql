create table Account(
    Id int primary key,
    AccountName nvarchar(25),
    Balance int
);

insert into Account values(1, 'Mark', 1000);
insert into Account values(2, 'Mary', 2000);


-- Transaction, kus mõlemad uuendatavad read peavad õnnestuma, et muudatused jääksid kehtima

begin try
    begin transaction
        update Account set Balance = Balance - 100 where id = 1
        update Account set Balance = Balance + 100 where id = 3
    commit transaction
    print 'Transaction completed successfully'
end try
begin catch
    rollback transaction
    print 'Transaction failed'
end catch
go

select * from Account;

-- ADVENTUREWORKS ANDMEBAASI TAASTAMINE --
-- https://www.linkedin.com/pulse/restoring-adventureworks-database-sql-servercontainer-daniel-anselmo-qgpwf
USE [master];
GO

RESTORE FILELISTONLY
FROM DISK = '/var/opt/mssql/data/AdventureWorksLT2019.bak';

RESTORE DATABASE AdventureWorksLT2019
FROM DISK = '/var/opt/mssql/data/AdventureWorksLT2019.bak'
WITH
    MOVE 'AdventureWorksLT2019_Data' TO '/var/opt/mssql/data/AdventureWorksLT2019.mdf',
    MOVE 'AdventureWorksLT2019_Log' TO '/var/opt/mssql/data/AdventureWorksLT2019.ldf',
    REPLACE;

select user_name();

-- Inline funktsioon, mis tagastab kõik kliendid.
-- Tabel: SalesLT.Customer
use AdventureWorksLT2019;

create function GetAllCustomers_ITVF()
returns table as
return (select * from SalesLT.Customer);

select * from GetAllCustomers_ITVF();

-- Funktsioon, mis võtab @CustomerID ja tagastab:
-- FirstName
-- LastName
create function GetCustomerByID_ITVF(@CustomerID int)
returns table
as
return (select FirstName, LastName from SalesLT.Customer
    where CustomerID = @CustomerID);

select * from GetCustomerByID_ITVF(1);

-- Funktsioon, mis võtab @CustomerID ja tagastab kõik selle kliendi tellimused
-- Tabel: SalesLT.SalesOrderHeader
create function GetOrdersByCustomer_ITVF(@CustomerID int)
returns table as
return (select * from SalesLT.SalesOrderHeader
                 where CustomerId = @CustomerID)

select * from GetOrdersByCustomer_ITVF(29736);

-- Funktsioon, mis võtab @MinPrice, @MaxPrice ja tagastab tooted hinnavahemikus
-- Tabel: SalesLT.Product
create function GetProductsByPrice_ITVF(@MinPrice money, @MaxPrice money)
returns table as
    return (select * from SalesLT.Product
    where ListPrice <= @MaxPrice and ListPrice >= @MinPrice);

select * from GetProductsByPrice_ITVF(1000, 2000);

-- Funktsioon, mis tagastab TOP 10 kõige kallimat toodet
create function GetTopExpensiveProducts_ITVF()
returns table as
return(select top 10 * from SalesLT.Product order by ListPrice desc);

select * from GetTopExpensiveProducts_ITVF();
