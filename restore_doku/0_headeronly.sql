/* ======================================================================
   Paso 0 (solo lectura): qué contiene el dump y qué tamaño de data y log
   necesita la base destino. No carga nada.
   Cambiar la ruta del .dmp si hace falta.
   Correr con:  correr_sql.bat 0_headeronly.sql
   ====================================================================== */
load database BAS_OLD from 'C:\backup-SYB\BAS_20261118_211256.dmp' with headeronly
go
/* Tamaño actual de BAS, para comparar */
use BAS
go
sp_helpdb BAS
go
