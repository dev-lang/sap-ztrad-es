/* ======================================================================
   2_doku_s.sql - Que son los documentos F1 que quedan en idioma S.
   SOLO LECTURA. DOKHL no tiene columnas IMAGE; DOKCLU no se lee.
   Correr con:  correr_sql.bat sql\02_doku_s.sql
   ====================================================================== */
set nocount on
go
print '=== DOKHL idioma S por clase de documento (ID) y si existe en E ==='
select h.ID, count(*) as docs_s,
       sum(case when exists (select 1 from BAS.SAPSR3.DOKHL e noholdlock
                             where e.ID = h.ID and e.OBJECT = h.OBJECT and e.TYP = h.TYP and e.LANGU = 'E') then 1 else 0 end) as con_e
from BAS.SAPSR3.DOKHL h noholdlock where h.LANGU = 'S' group by h.ID order by 2 desc
go
print '=== DOKHL idioma S en BAS_OLD (18/11) por ID ==='
select ID, count(*) as docs_s from BAS_OLD.SAPSR3.DOKHL noholdlock where LANGU = 'S' group by ID order by 2 desc
go
print '=== Muestra: 40 documentos S (todas las columnas de DOKHL) ==='
set rowcount 40
select * from BAS.SAPSR3.DOKHL noholdlock where LANGU = 'S' order by ID, OBJECT
go
set rowcount 0
go
print '=== Los 242 que estaban el 18/11 y hoy no ==='
set rowcount 60
select o.ID, o.OBJECT, o.TYP, o.DOKVERSION from BAS_OLD.SAPSR3.DOKHL o noholdlock
where o.LANGU = 'S' and not exists (select 1 from BAS.SAPSR3.DOKHL n noholdlock
  where n.ID = o.ID and n.OBJECT = o.OBJECT and n.TYP = o.TYP and n.LANGU = 'S' and n.DOKVERSION = o.DOKVERSION)
order by o.ID, o.OBJECT
go
set rowcount 0
go
