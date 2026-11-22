/* ======================================================================
   Paso 4: auditoría del restore (solo lectura). Compara BAS contra
   BAS_OLD para los objetos de objetos.txt:
   A) toda tabla de SAPSR3 que empiece con DOK o DOC y tenga columnas ID
      y OBJECT: filas por tabla (sin idioma S) en BAS y en el dump
   B) DOKCL, DOKCLU, DOKHL y DOKIL: conteos con y sin idioma S
   C) fila por fila: filas del dump que no están idénticas en BAS, y filas
      de BAS que no estaban en el dump (todo debería dar 0)
   Reúne lo que se corrió como 4_auditoria, 5_auditoria_b y 6_auditoria_c,
   con estas correcciones ya aplicadas:
     - Sybase exige DECLARE CURSOR solo en su batch: A) usa un while
     - VARDATA (DOKCLU) es IMAGE y no se puede comparar en un WHERE: se
       compara PAGELG + datalength(VARDATA)
     - "dump" es palabra reservada: los alias son en_bas / en_dump
   Plantilla: generar_sql.py la completa y deja la versión en generado\.
   Correr con:  correr_sql.bat generado\4_auditoria.sql
   ====================================================================== */
/* Lista de objetos */
if object_id('tempdb..zdoku_list') is not null drop table tempdb..zdoku_list
go
create table tempdb..zdoku_list (ID varchar(2) not null, OBJECT varchar(60) not null)
go
/* @@LISTA_OBJETOS@@ */
create unique index zdoku_list_i on tempdb..zdoku_list (ID, OBJECT)
go
select 'lista' as paso, count(*) as objetos from tempdb..zdoku_list
go
/* A) tablas candidatas */
if object_id('tempdb..zdoku_tabs') is not null drop table tempdb..zdoku_tabs
go
create table tempdb..zdoku_tabs (name varchar(60) not null, hasl int not null)
go
insert tempdb..zdoku_tabs
  select o.name, (select count(*) from BAS..syscolumns c3 where c3.id = o.id and c3.name = 'LANGU')
    from BAS..sysobjects o
   where o.type = 'U' and (o.name like 'DOK%' or o.name like 'DOC%')
     and exists (select 1 from BAS..syscolumns c1 where c1.id = o.id and c1.name = 'ID')
     and exists (select 1 from BAS..syscolumns c2 where c2.id = o.id and c2.name = 'OBJECT')
     and user_name(o.uid) = 'SAPSR3'
go
select 'tablas candidatas' as que, name from tempdb..zdoku_tabs order by name
go
declare @t varchar(60), @hasl int, @sql varchar(2000)
select @t = min(name) from tempdb..zdoku_tabs
while @t is not null
begin
  select @hasl = hasl from tempdb..zdoku_tabs where name = @t
  select @sql = 'select ''' + @t + ''' as tabla, '
    + '(select count(*) from BAS.SAPSR3.' + @t + ' x, tempdb..zdoku_list l where x.ID = l.ID and x.OBJECT = l.OBJECT'
    + case when @hasl > 0 then ' and x.LANGU <> ''S''' else '' end + ') as en_bas, '
    + '(select count(*) from BAS_OLD.SAPSR3.' + @t + ' x, tempdb..zdoku_list l where x.ID = l.ID and x.OBJECT = l.OBJECT'
    + case when @hasl > 0 then ' and x.LANGU <> ''S''' else '' end + ') as en_dump'
  exec (@sql)
  select @t = min(name) from tempdb..zdoku_tabs where name > @t
end
go
drop table tempdb..zdoku_tabs
go
/* B) conteos por tabla, con y sin idioma S */
select 'DOKCL columnas' as que, c.name from BAS..syscolumns c, BAS..sysobjects o where o.id = c.id and o.name = 'DOKCL' and user_name(o.uid) = 'SAPSR3' order by c.colid
go
select 'DOKCL total' as tabla,
  (select count(*) from BAS.SAPSR3.DOKCL x, tempdb..zdoku_list l where x.ID = l.ID and x.OBJECT = l.OBJECT) as en_bas,
  (select count(*) from BAS_OLD.SAPSR3.DOKCL x, tempdb..zdoku_list l where x.ID = l.ID and x.OBJECT = l.OBJECT) as en_dump
go
select 'DOKCLU no-S' as tabla,
  (select count(*) from BAS.SAPSR3.DOKCLU x, tempdb..zdoku_list l where x.ID = l.ID and x.OBJECT = l.OBJECT and x.LANGU <> 'S') as en_bas,
  (select count(*) from BAS_OLD.SAPSR3.DOKCLU x, tempdb..zdoku_list l where x.ID = l.ID and x.OBJECT = l.OBJECT and x.LANGU <> 'S') as en_dump
go
select 'DOKCLU S' as tabla,
  (select count(*) from BAS.SAPSR3.DOKCLU x, tempdb..zdoku_list l where x.ID = l.ID and x.OBJECT = l.OBJECT and x.LANGU = 'S') as en_bas,
  (select count(*) from BAS_OLD.SAPSR3.DOKCLU x, tempdb..zdoku_list l where x.ID = l.ID and x.OBJECT = l.OBJECT and x.LANGU = 'S') as en_dump
go
select 'DOKHL no-S' as tabla,
  (select count(*) from BAS.SAPSR3.DOKHL x, tempdb..zdoku_list l where x.ID = l.ID and x.OBJECT = l.OBJECT and x.LANGU <> 'S') as en_bas,
  (select count(*) from BAS_OLD.SAPSR3.DOKHL x, tempdb..zdoku_list l where x.ID = l.ID and x.OBJECT = l.OBJECT and x.LANGU <> 'S') as en_dump
go
select 'DOKHL S' as tabla,
  (select count(*) from BAS.SAPSR3.DOKHL x, tempdb..zdoku_list l where x.ID = l.ID and x.OBJECT = l.OBJECT and x.LANGU = 'S') as en_bas,
  (select count(*) from BAS_OLD.SAPSR3.DOKHL x, tempdb..zdoku_list l where x.ID = l.ID and x.OBJECT = l.OBJECT and x.LANGU = 'S') as en_dump
go
select 'DOKIL no-S' as tabla,
  (select count(*) from BAS.SAPSR3.DOKIL x, tempdb..zdoku_list l where x.ID = l.ID and x.OBJECT = l.OBJECT and x.LANGU <> 'S') as en_bas,
  (select count(*) from BAS_OLD.SAPSR3.DOKIL x, tempdb..zdoku_list l where x.ID = l.ID and x.OBJECT = l.OBJECT and x.LANGU <> 'S') as en_dump
go
select 'DOKIL S' as tabla,
  (select count(*) from BAS.SAPSR3.DOKIL x, tempdb..zdoku_list l where x.ID = l.ID and x.OBJECT = l.OBJECT and x.LANGU = 'S') as en_bas,
  (select count(*) from BAS_OLD.SAPSR3.DOKIL x, tempdb..zdoku_list l where x.ID = l.ID and x.OBJECT = l.OBJECT and x.LANGU = 'S') as en_dump
go
/* C) fila por fila: filas del dump (no S) que no tienen una fila idéntica en BAS */
select 'DOKHL distintas' as que, count(*) from BAS_OLD.SAPSR3.DOKHL o, tempdb..zdoku_list l
 where o.ID = l.ID and o.OBJECT = l.OBJECT and o.LANGU <> 'S'
   and not exists (select 1 from BAS.SAPSR3.DOKHL x where x.ID = o.ID and x.OBJECT = o.OBJECT and x.LANGU = o.LANGU
                   and x.TYP = o.TYP and x.DOKVERSION = o.DOKVERSION and x.DOKSTATE = o.DOKSTATE
                   and x.DOKFORM = o.DOKFORM and x.DOKSTYLE = o.DOKSTYLE and x.DOKLDATE = o.DOKLDATE and x.DOKLTIME = o.DOKLTIME)
go
select 'DOKIL distintas' as que, count(*) from BAS_OLD.SAPSR3.DOKIL o, tempdb..zdoku_list l
 where o.ID = l.ID and o.OBJECT = l.OBJECT and o.LANGU <> 'S'
   and not exists (select 1 from BAS.SAPSR3.DOKIL x where x.ID = o.ID and x.OBJECT = o.OBJECT and x.LANGU = o.LANGU
                   and x.TYP = o.TYP and x.VERSION = o.VERSION and x.MASTERLANG = o.MASTERLANG
                   and x.TXTLINES = o.TXTLINES and x.DOKSTATE = o.DOKSTATE and x.SELFDEF = o.SELFDEF)
go
select 'DOKCLU distintas (clave+PAGELG+largo)' as que, count(*) from BAS_OLD.SAPSR3.DOKCLU o, tempdb..zdoku_list l
 where o.ID = l.ID and o.OBJECT = l.OBJECT and o.LANGU <> 'S'
   and not exists (select 1 from BAS.SAPSR3.DOKCLU x where x.ID = o.ID and x.OBJECT = o.OBJECT and x.LANGU = o.LANGU
                   and x.TYP = o.TYP and x.DOKVERSION = o.DOKVERSION and x.PAGENO = o.PAGENO
                   and x.PAGELG = o.PAGELG and datalength(x.VARDATA) = datalength(o.VARDATA))
go
/* filas en BAS (no S) que no estaban en el dump */
select 'DOKHL de más en BAS' as que, count(*) from BAS.SAPSR3.DOKHL x, tempdb..zdoku_list l
 where x.ID = l.ID and x.OBJECT = l.OBJECT and x.LANGU <> 'S'
   and not exists (select 1 from BAS_OLD.SAPSR3.DOKHL o where o.ID = x.ID and o.OBJECT = x.OBJECT and o.LANGU = x.LANGU and o.TYP = x.TYP and o.DOKVERSION = x.DOKVERSION)
go
select 'DOKIL de más en BAS' as que, count(*) from BAS.SAPSR3.DOKIL x, tempdb..zdoku_list l
 where x.ID = l.ID and x.OBJECT = l.OBJECT and x.LANGU <> 'S'
   and not exists (select 1 from BAS_OLD.SAPSR3.DOKIL o where o.ID = x.ID and o.OBJECT = x.OBJECT and o.LANGU = x.LANGU and o.TYP = x.TYP and o.VERSION = x.VERSION)
go
select 'DOKCLU de más en BAS' as que, count(*) from BAS.SAPSR3.DOKCLU x, tempdb..zdoku_list l
 where x.ID = l.ID and x.OBJECT = l.OBJECT and x.LANGU <> 'S'
   and not exists (select 1 from BAS_OLD.SAPSR3.DOKCLU o where o.ID = x.ID and o.OBJECT = x.OBJECT and o.LANGU = x.LANGU and o.TYP = x.TYP and o.DOKVERSION = x.DOKVERSION and o.PAGENO = x.PAGENO)
go
drop table tempdb..zdoku_list
go
