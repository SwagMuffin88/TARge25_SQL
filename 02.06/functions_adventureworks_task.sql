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

-- 1. Inline funktsioon, mis tagastab kõik kliendid.
-- Tabel: SalesLT.Customer
use AdventureWorksLT2019;

create function GetAllCustomers_ITVF()
returns table as
return (select * from SalesLT.Customer);

select * from GetAllCustomers_ITVF();

-- 2. Funktsioon, mis võtab @CustomerID ja tagastab:
-- FirstName
-- LastName
create function GetCustomerByID_ITVF(@CustomerID int)
returns table
as
return (select FirstName, LastName from SalesLT.Customer
    where CustomerID = @CustomerID);

select * from GetCustomerByID_ITVF(1);

-- 3. Funktsioon, mis võtab @CustomerID ja tagastab kõik selle kliendi tellimused
-- Tabel: SalesLT.SalesOrderHeader
create function GetOrdersByCustomer_ITVF(@CustomerID int)
returns table as
return (select * from SalesLT.SalesOrderHeader
                 where CustomerId = @CustomerID)

select * from GetOrdersByCustomer_ITVF(29736);

-- 4. Funktsioon, mis võtab @MinPrice, @MaxPrice ja tagastab tooted hinnavahemikus
-- Tabel: SalesLT.Product
create function GetProductsByPrice_ITVF(@MinPrice money, @MaxPrice money)
returns table as
    return (select * from SalesLT.Product
    where ListPrice <= @MaxPrice and ListPrice >= @MinPrice);

select * from GetProductsByPrice_ITVF(1000, 2000);

-- 5. Funktsioon, mis tagastab TOP 10 kõige kallimat toodet
create function GetTopExpensiveProducts_ITVF()
returns table as
return(select top 10 * from SalesLT.Product order by ListPrice desc);

select * from GetTopExpensiveProducts_ITVF();

-- 6. Funktsioon, mis võtab @CustomerID ja tagastab tabeli, kus on:
-- nimi (First + Last kokku)
-- email
-- telefon
-- Tabel: SalesLT.Customer
-- Kasuta @Result TABLE

create function GetCustomerFullInfo_MSTVF()
returns @Result table(Name nvarchar(100), EmailAddress nvarchar(50), Phone phone)
as begin
    insert into @Result
    select FirstName + ' ' + LastName AS Name,
           EmailAddress, Phone
    from SalesLT.Customer
    return;
end

select * from GetCustomerFullInfo_MSTVF();

-- 7. Funktsioon, mis võtab @CustomerID ja tagastab:
-- tellimuste arv
-- kogusumma

-- Tabel: SalesLT.SalesOrderHeader
create function GetCustomerOrderSummary_MSTVF(@CustomerId int)
returns @Result table(NrOfOrders int, TotalPrice money)
as begin
    insert into @Result
    select count(SalesOrderID),
           sum(TotalDue)
    from SalesLT.SalesOrderHeader
    where CustomerID = @CustomerId
return
end

select * from GetCustomerOrderSummary_MSTVF(29736);

-- 8. Funktsioon, mis tagastab kõik tooted + hinnaklass:
-- "Odav", "Keskmine", "Kallis"
-- Tabel: SalesLT.Product
create function GetProductPriceCategory_MSTVF()
returns @Result table (Id int, ProductName nvarchar(100), ListPrice money, PriceRange nvarchar(10))
as begin
    insert into @Result
    select ProductId, Name, ListPrice,
           -- Hinnaklassi määramine:
        CASE
            WHEN ListPrice < 800 THEN 'LowEnd'
            WHEN ListPrice >= 800 AND ListPrice <= 2000 THEN 'Middle'
            WHEN ListPrice > 2000 THEN 'HighEnd'
            ELSE 'Unknown' -- Juhuks, kui hind peaks olema NULL või puudu
        END AS PriceRange
    from SalesLT.Product
    return
end


select * from GetProductPriceCategory_MSTVF();

-- 9. Funktsioon, mis tagastab ainult need kliendid, kellel on vähemalt 1 tellimus
-- Tabelid: SalesLT.Customer, SalesLT.SalesOrderHeader
create function GetCustomersWithOrders_MSTVF()
returns @Result table(
    CustomerID INT,
    FirstName NVARCHAR(50),
    LastName NVARCHAR(50),
    CompanyName NVARCHAR(128),
    EmailAddress NVARCHAR(50)
)
as begin
    insert into @Result(CustomerID, FirstName, LastName, CompanyName, EmailAddress)
    select CustomerID, FirstName, LastName, CompanyName, EmailAddress
    from SalesLT.Customer
    where
        CustomerID in (select CustomerID from SalesLT.SalesOrderHeader)
    return
end

select * from GetCustomersWithOrders_MSTVF();

-- 10. Funktsioon, mis tagastab TOP 5 klienti koos nimega, kogukuluga
create function GetTopCustomersBySpending_MSTVF()
returns table as
return (
    select top 5 * from (
        SELECT c.CustomerID,
                c.FirstName,
                c.LastName,
                c.CompanyName,
                sum(o.TotalDue) as TotalSpend
         from GetCustomersWithOrders_MSTVF() c
                  inner join SalesLT.SalesOrderHeader o on c.CustomerID = o.CustomerId
         group by c.CustomerID, c.FirstName, c.LastName, c.CompanyName) as co order by TotalSpend desc)

select * from dbo.GetTopCustomersBySpending_MSTVF();