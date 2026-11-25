/* 12_dump_bas.sql - Dump completo de BAS despues del paso 1 (reversion a ingles),
   antes del paso 2 (borrado del espanol). Correr: correr_sql.bat sql\12_dump_bas.sql */
select 'inicio', getdate()
go
dump database BAS to 'C:\backup-SYB\BAS_20261124_paso1.dmp'
go
select 'fin', getdate()
go
