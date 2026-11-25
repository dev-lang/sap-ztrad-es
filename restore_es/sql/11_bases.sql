/* 11_bases.sql - SOLO LECTURA. Que bases hay montadas y cual usa SAP hoy.
   Correr: correr_sql.bat sql\11_bases.sql */
set nocount on
go
select 'inicio', getdate()
go
print '=== Bases del servidor (crdate = creacion/carga) ==='
select name, crdate, dumptrdate from master..sysdatabases order by name
go
print '=== BAS: ultimo job y ultimo job ZTRAD_HTTP (si es hoy, SAP esta usando BAS) ==='
select 'BAS' base, max(SDLSTRTDT + ' ' + SDLSTRTTM) ultimo_job from BAS.SAPSR3.TBTCO noholdlock
select 'BAS' base, max(SDLSTRTDT + ' ' + SDLSTRTTM) ultimo_ztrad from BAS.SAPSR3.TBTCO noholdlock where JOBNAME = 'ZTRAD_HTTP'
go
print '=== BAS_OLD (si existe): ultimo job ==='
if db_id('BAS_OLD') is not null
  exec ('select ''BAS_OLD'' base, max(SDLSTRTDT + '' '' + SDLSTRTTM) ultimo_job from BAS_OLD.SAPSR3.TBTCO noholdlock')
else
  print 'No existe BAS_OLD'
go
print '=== Conexiones activas por base (SAP = muchas en la misma base) ==='
select db_name(dbid) base, count(*) conexiones from master..sysprocesses where suid > 0 group by db_name(dbid) order by 2 desc
go
select 'fin', getdate()
go
