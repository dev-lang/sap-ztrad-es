/* 15_dump_bas_final.sql - Dump de BAS con el paso 2 completo (80 tablas + DD04T + text pools).
   Comprimido (nivel 1). Correr: correr_sql.bat sql\15_dump_bas_final.sql */
select 'inicio', getdate()
go
dump database BAS to 'C:\backup-SYB\BAS_20261124_final.dmp' with compression = 1
go
select 'fin', getdate()
go
