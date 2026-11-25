/* ======================================================================
   3_jobs_11oct.sql - Que se corrio el 11-12/10/2026 al clasificar el
   espanol (S). SOLO LECTURA sobre TBTCO/TBTCP (jobs) y T002C.
   Correr con:  correr_sql.bat sql\03_jobs_11oct.sql
   ====================================================================== */
set nocount on
go
print '=== Jobs del 10/10 al 13/10 (TBTCO) ==='
select JOBNAME, JOBCOUNT, SDLUNAME, STRTDATE, STRTTIME, ENDDATE, ENDTIME, STATUS
from BAS.SAPSR3.TBTCO noholdlock
where STRTDATE between '20261010' and '20261013' or SDLSTRTDT between '20261010' and '20261013'
order by STRTDATE, STRTTIME
go
print '=== Pasos de esos jobs (TBTCP): programa y variante ==='
select p.JOBNAME, p.JOBCOUNT, p.STEPCOUNT, p.PROGNAME, p.VARIANT, p.AUTHCKNAM, p.SDLDATE, p.SDLTIME
from BAS.SAPSR3.TBTCP p noholdlock, BAS.SAPSR3.TBTCO o noholdlock
where o.JOBNAME = p.JOBNAME and o.JOBCOUNT = p.JOBCOUNT
  and (o.STRTDATE between '20261010' and '20261013' or o.SDLSTRTDT between '20261010' and '20261013')
order by p.SDLDATE, p.SDLTIME, p.JOBNAME, p.STEPCOUNT
go
print '=== Jobs de idioma de cualquier fecha (RSTLAN*, RSREFILL, SMLT*, *LANG*) ==='
select o.JOBNAME, o.JOBCOUNT, o.STRTDATE, o.STRTTIME, o.ENDDATE, o.ENDTIME, o.STATUS, p.PROGNAME, p.VARIANT
from BAS.SAPSR3.TBTCO o noholdlock, BAS.SAPSR3.TBTCP p noholdlock
where o.JOBNAME = p.JOBNAME and o.JOBCOUNT = p.JOBCOUNT
  and (p.PROGNAME like 'RSTLAN%' or p.PROGNAME like 'RSREFILL%' or p.PROGNAME like 'RSLANG%'
       or o.JOBNAME like 'SMLT%' or o.JOBNAME like '%LANG%' or o.JOBNAME like '%SUPPL%')
order by o.STRTDATE, o.STRTTIME
go
print '=== T002C completo para S ==='
select * from BAS.SAPSR3.T002C noholdlock where SPRAS = 'S'
go
