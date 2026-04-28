-- 21.04
-- Temporary tables - tabelid, mis on loodud ajutiselt ja kustutatakse automaatselt.
-- Neid on kahte tüüpi: local temporary tables, global temporary tables
-- Local - #; Global - ##
create table #PersonDetails(Id int, Name nvarchar(30))

-- Temp tabeleid ei salvestata tavalise andmebaasi tabelite alla, vaid süsteemsesse andmebaasi tempdb.

insert into #PersonDetails values(1, 'Mike')
insert into #PersonDetails values(2, 'Max')
insert into #PersonDetails values(3, 'Uhura')
go

select * from #PersonDetails

-- Objekti saab otsida üles:
select Name from tempdb.sys.tables
where Name like '#PersonDetails%'

drop table #PersonDetails

-- Stored procedure - loob local temp tabeli ja täidab selle andmetega --
create proc spCreateLocalTempTable
as begin
    create table #PersonDetails(Id int, Name nvarchar(30))

    insert into #PersonDetails values(1, 'Mike')
    insert into #PersonDetails values(2, 'Max')
    insert into #PersonDetails values(3, 'Uhura')

    select * from #PersonDetails
end
go

exec spCreateLocalTempTable; -- <- miskipärast jääb lõputult executima

-- Globaalse tabeli loomine
create table ##GlobalPersonDetails(Id int, Name nvarchar(20))

-- Erinevused globaalse ja lokaalse tabeli vahel:
-- 1. Lokaalne on nähtav ainult sellele kasutajale/sessioonile, kes selle lõi, globaalne on nähtav kõikidele
--      kasutajatele ja kõikidele aktiivsetele sessioonidele andmebaasis.
-- 2. Lokaalne tabel kustutatakse automaatselt, kui tabeli loonud sessioon (aken/ühendus) suletakse.
--      Globaalne kustutatakse siis, kui kõik seda tabelit kasutavad sessioonid on suletud.
-- 3. Lokaalne on kasutuse poolest rohkem levinud, kui globaalne. Viimast kasutatakse siis, kui
--      on vaja andmeid liigutada erinevate rakenduste või kasutajate vahel ilma päris tabelit loomata.