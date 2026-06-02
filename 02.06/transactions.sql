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

-- Mõned levinumad transacions probleemid:
     --1. Dirty read
    -- 2. Lost updates
    -- 3. Nonrepeatable reads
    -- 4. Phantom read

-- Lahendamiseks tuleb lubada korraga ühel kasutajal üht tehingut teha. Siis satuvad kõik
-- tehingud järjekorda ja neil võib tekkida vajadus kaua ootata, enne kui tekib võimalus tehingut teha

-- Kui lubada samaaegselt kõik tehingud ära teha, siis see omakorda tekitab probleeme.
    -- Nende lahendamiseks pakub MSSQL server erinevaid tehinguisolatsiooni tasemeid,
-- et tasakaalustada samaaegsete andmete CRUD probleeme:

    -- 1. Read uncommited (lugemine teostamata)
    -- 2. Read committed (teostatud lugemine)
    -- 3. Repeatable read (korduv lugemine)
    -- 4. Snapshot (kuvatõmmis)
    -- 5. Serializable (serialiseerimine)

-- Igale probleemile tuleb läheneda juhtumipõhiselt.

-- Dirty read:
create table Inventory(
    Id int identity primary key,
    Product nvarchar(100),
    ItemsInStock int
)
go

insert into Inventory values ('TV', 10)
select * from Inventory;

begin transaction
update Inventory set ItemsInStock = 9 where Id = 1; -- Kliendile tuleb arve
waitfor delay '00:00:15'; -- Ebapiisav saldojääk, teeb rollbacki
rollback transaction
-- Kui enne rollbacki teha päring teisest sessioonist samale andmebaasile, siis kuvatakse seal transactioni esimese poole tulemus,
    -- põhjustades vea

-- Lost update:
select * from Inventory
-- 1 transaction, 1 käsklus
begin transaction
    declare @ItemsInStock int
    select @ItemsInStock = ItemsInStock
    from Inventory where Id = 1;

    waitfor delay '00:00:15';
    set @ItemsInStock = @ItemsInStock

    update Inventory
    set ItemsInStock = @ItemsInStock
    where Id = 1

    print @ItemsInStock
commit transaction

select * from Inventory;

-- Non-repeatable read:
-- Kui üks tehing loeb samu andmeid kaks korda ja teine tehing uuendab neid esimese ning teise käsu vahel esimese
-- tehingu jooksutamise ajal.

begin transaction
    select ItemsInStock from Inventory where Id = 1

    waitfor delay '00:00:15'
    select ItemsInStock from Inventory where Id = 1
commit transaction
-- Non-repeatable read probleemi lahendamiseks kasutatakse esimese tehingu (transaction) ees käsklust:
    -- set transaction isolation level repeatable read

-- Phantom read:
use master;
drop table Employee;

create table Employee
(
    Id int primary key,
    Name nvarchar(30)
)

insert into Employee values (1, 'Mark')
insert into Employee values (2, 'Sara')
insert into Employee values (3, 'Mary')

select * from Employee;

set transaction isolation level serializable

begin transaction
    select * from Employee where Id between 1 and 3

    waitfor delay '00:00:10'

    select * from  Employee where Id between 1 and 3
commit transaction

select * from Employee

-- Deadlock
-- Juhtub, kui kaks või enam tehingut blokeerivad üksteist.
-- MS SQL serveris deadlocki tuvastamisel lukustatakse serveri lõm, mis töötab vaikimisi iga 5s järel,
-- et tuvastada ummikuid. Deadlocki leidmisel langeb selle intervall 5sek-lt 100 ms-le.

-- Tuvastamisel lõpetab andmebaasimootor D.L. ohvri tehingu ja valib ühe lõime "ohvriks".
-- Ohvri tehingut lükatakse tagasi ja tagastatakse rakendusele viga 1205.
-- Tehingu tagasilükkamine vabastab kõik selle tehingu valduses olnud lukud, mis võimaldab teiste tehingutel edasi liikuda.

-- DEADLOCK_PRIORITY:
-- Vaikimisi valib SQL Server tehingu, mille tagasilükkamine on kõige odavam
-- (võtab kõige vähem ressursse). Seansside prioriteeti saab muuta käsklusega SET DEADLOCK_PRIORITY

-- Kuidas "ohver" valitakse:
-- 1. Kui pr-d on erinevad, siis valitakse kõige madalama tähtsusega sessioon.
-- 2. Kui mõlemal sessioonil on sama prioriteet, siis valitakse tehing, mille tagasilükkamine on kõige vähem ressursinõudlikum.
-- 3. Kui mõlemal sessioonil on sama prioriteet ja sama ressursinõudlikkus, siis valitakse see juhuslikult.

-- https://learn.microsoft.com/en-us/sql/relational-databases/sql-server-deadlocks-guide?view=sql-server-ver17

-- https://dotnettutorials.net/lesson/sql-server-deadlock-examples/
-- Create table TableA
CREATE TABLE TableA
(
    ID INT,
    Name NVARCHAR(50)
)
Go

-- Insert some test data
INSERT INTO TableA values (101, 'Anurag')
INSERT INTO TableA values (102, 'Mohanty')
INSERT INTO TableA values (103, 'Pranaya')
INSERT INTO TableA values (104, 'Rout')
INSERT INTO TableA values (105, 'Sambit')
Go

-- Create table TableB
CREATE TABLE TableB
(
    ID INT,
    Name NVARCHAR(50)
)
Go

-- Insert some test data
INSERT INTO TableB values (1001, 'Priyanka')
INSERT INTO TableB values (1002, 'Dewagan')
INSERT INTO TableB values (1003, 'Preety')
Go

-- The following 2 transactions will result in a deadlock situation. Open 2 instances of [session].
-- From the first instance execute Transaction 1 code and from the second instance execute Transaction 2 code.

-- Transaction 1
BEGIN TRANSACTION
UPDATE TableA SET Name = 'Anurag From Transaction1' WHERE Id = 101

WAITFOR DELAY '00:00:15'

UPDATE TableB SET Name = 'Priyanka From Transaction1' WHERE Id = 1001
COMMIT TRANSACTION

-- -- Transaction 2 (separate session)
-- BEGIN TRANSACTION
-- UPDATE TableB SET Name = 'Priyanka From Transaction2' WHERE Id = 1001
--
-- WAITFOR DELAY '00:00:15'
--
-- UPDATE TableA SET Name = 'Anurag From Transaction2' WHERE Id = 101
-- Commit Transaction