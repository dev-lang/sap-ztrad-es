/* ======================================================================
   Paso 1: cargar el dump en una base APARTE (BAS_OLD).
   NUNCA hacer load sobre BAS.
   Antes:
     - mkdir C:\backup-SYB\BAS_OLD
     - espacio libre para data + log (ver el headeronly del paso 0)
   Correr con:  correr_sql.bat 1_cargar_dump.sql
   ====================================================================== */
/* Tamaños según el headeronly del dump del 18/11/2026 (páginas de 16 KB):
     data 5.767.168 páginas = 90.112 MB
     log    655.360 páginas = 10.240 MB   (en ese orden)
   Para otro dump, cambiar los tamaños y, si hace falta, las rutas physname. */
use master
go
disk init name = 'BAS_OLD_data', physname = 'C:\backup-SYB\BAS_OLD\BAS_OLD_data.dat', size = '90112M'
go
disk init name = 'BAS_OLD_log',  physname = 'C:\backup-SYB\BAS_OLD\BAS_OLD_log.dat',  size = '10240M'
go
create database BAS_OLD on BAS_OLD_data = '90112M' log on BAS_OLD_log = '10240M' for load
go
/* Cargar y poner online */
load database BAS_OLD from 'C:\backup-SYB\BAS_20261118_211256.dmp'
go
online database BAS_OLD
go
/* Control rápido: un documento que tiene que estar en el dump (debe dar > 0) */
select count(*) from BAS_OLD.SAPSR3.DOKIL where ID = 'DE' and OBJECT = 'ME2O_DETAIL'
go
/* ----------------------------------------------------------------------
   Al terminar el restore y la auditoría, borrar BAS_OLD (correr a mano):
     use master
     go
     drop database BAS_OLD
     go
     sp_dropdevice BAS_OLD_data
     go
     sp_dropdevice BAS_OLD_log
     go
   y después borrar a mano los .dat de C:\backup-SYB\BAS_OLD\
   ---------------------------------------------------------------------- */
