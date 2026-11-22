/* ======================================================================
   Paso 3: restore de las líneas de texto de la documentación.
   DOKTL no es una tabla física: es una tabla cluster y las líneas se
   guardan en DOKCLU (clave ID, OBJECT, LANGU, TYP, DOKVERSION, PAGENO;
   el texto va comprimido en VARDATA). Por eso un insert en DOKTL desde
   la base falla, y se copia DOKCLU entera para esos objetos.
   Copia SOLO LANGU <> 'S' y solo filas que falten.
   Plantilla: generar_sql.py la completa y deja la versión en generado\.
   Correr con:  correr_sql.bat generado\3_restore_dokclu.sql
   ====================================================================== */
/* DOKCLU debe existir en las dos bases con owner SAPSR3 */
select 'BAS' as base, user_name(uid) as owner from BAS..sysobjects where name = 'DOKCLU'
select 'BAS_OLD' as base, user_name(uid) as owner from BAS_OLD..sysobjects where name = 'DOKCLU'
go
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
/* Control ANTES */
select 'BAS hoy DOKCLU' as que, count(*) from BAS.SAPSR3.DOKCLU h, tempdb..zdoku_list l where h.ID = l.ID and h.OBJECT = l.OBJECT
go
select 'DUMP DOKCLU no-S' as que, count(*) from BAS_OLD.SAPSR3.DOKCLU o, tempdb..zdoku_list l where o.ID = l.ID and o.OBJECT = l.OBJECT and o.LANGU <> 'S'
go
/* Copia */
begin tran
insert into BAS.SAPSR3.DOKCLU
  select o.* from BAS_OLD.SAPSR3.DOKCLU o, tempdb..zdoku_list l
   where o.ID = l.ID and o.OBJECT = l.OBJECT and o.LANGU <> 'S'
     and not exists (select 1 from BAS.SAPSR3.DOKCLU x
                      where x.ID = o.ID and x.OBJECT = o.OBJECT and x.LANGU = o.LANGU
                        and x.TYP = o.TYP and x.DOKVERSION = o.DOKVERSION and x.PAGENO = o.PAGENO)
select 'insert DOKCLU' as que, @@rowcount
commit tran
go
/* Control DESPUÉS de las tres tablas (BAS debe igualar al DUMP en cada una) */
select 'BAS DOKHL no-S' as que, count(*) from BAS.SAPSR3.DOKHL h, tempdb..zdoku_list l where h.ID = l.ID and h.OBJECT = l.OBJECT and h.LANGU <> 'S'
go
select 'DUMP DOKHL no-S' as que, count(*) from BAS_OLD.SAPSR3.DOKHL o, tempdb..zdoku_list l where o.ID = l.ID and o.OBJECT = l.OBJECT and o.LANGU <> 'S'
go
select 'BAS DOKIL no-S' as que, count(*) from BAS.SAPSR3.DOKIL h, tempdb..zdoku_list l where h.ID = l.ID and h.OBJECT = l.OBJECT and h.LANGU <> 'S'
go
select 'DUMP DOKIL no-S' as que, count(*) from BAS_OLD.SAPSR3.DOKIL o, tempdb..zdoku_list l where o.ID = l.ID and o.OBJECT = l.OBJECT and o.LANGU <> 'S'
go
select 'BAS DOKCLU no-S' as que, count(*) from BAS.SAPSR3.DOKCLU h, tempdb..zdoku_list l where h.ID = l.ID and h.OBJECT = l.OBJECT and h.LANGU <> 'S'
go
select 'DUMP DOKCLU no-S' as que, count(*) from BAS_OLD.SAPSR3.DOKCLU o, tempdb..zdoku_list l where o.ID = l.ID and o.OBJECT = l.OBJECT and o.LANGU <> 'S'
go
select 'BAS objetos con DOKIL E' as que, count(distinct h.OBJECT) from BAS.SAPSR3.DOKIL h, tempdb..zdoku_list l where h.ID = l.ID and h.OBJECT = l.OBJECT and h.LANGU = 'E'
go
select 'BAS docs S que quedaron' as que, count(*) from BAS.SAPSR3.DOKHL h, tempdb..zdoku_list l where h.ID = l.ID and h.OBJECT = l.OBJECT and h.LANGU = 'S'
go
drop table tempdb..zdoku_list
go
