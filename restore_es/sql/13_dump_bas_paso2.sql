/* 13_dump_bas_paso2.sql - Dump de BAS despues del paso 2 (borrado del espanol en 80 tablas),
   antes de tocar los text pools. Comprimido (nivel 1) para que entre en el disco.
   Correr: correr_sql.bat sql\13_dump_bas_paso2.sql */
select 'inicio', getdate()
go
dump database BAS to 'C:\backup-SYB\BAS_20261124_paso2.dmp' with compression = 1
go
select 'fin', getdate()
go
