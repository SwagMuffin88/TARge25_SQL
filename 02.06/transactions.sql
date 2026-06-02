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
    -- 4. Phantom rea

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

