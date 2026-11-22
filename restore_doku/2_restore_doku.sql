/* ======================================================================
   Paso 2: restore de las cabeceras de la documentación (DOKHL, DOKIL)
   desde BAS_OLD hacia BAS, para los objetos de objetos.txt.
   Copia SOLO las filas con LANGU <> 'S' que falten en BAS: no pisa nada
   existente. El idioma S no se restaura.
   Las líneas de texto (DOKTL) van en el paso 3: en este sistema DOKTL es
   una tabla cluster y las filas físicas están en DOKCLU.
   Plantilla: no se corre directo. generar_sql.py la completa con la lista
   y deja la versión para correr en generado\.
   Correr con:  correr_sql.bat generado\2_restore_doku.sql
   ====================================================================== */
/* Owner de DOKHL en BAS y en BAS_OLD (debe decir SAPSR3; si no, reemplazar SAPSR3 abajo) */
select 'BAS' as base, user_name(uid) as owner from BAS..sysobjects where name = 'DOKHL'
select 'BAS_OLD' as base, user_name(uid) as owner from BAS_OLD..sysobjects where name = 'DOKHL'
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
/* Control ANTES (lo que hay hoy en BAS y lo que hay en el dump) */
select 'BAS hoy DOKHL' as que, count(*) from BAS.SAPSR3.DOKHL h, tempdb..zdoku_list l where h.ID = l.ID and h.OBJECT = l.OBJECT
select 'BAS hoy DOKIL' as que, count(*) from BAS.SAPSR3.DOKIL h, tempdb..zdoku_list l where h.ID = l.ID and h.OBJECT = l.OBJECT
select 'DUMP DOKHL no-S' as que, count(*) from BAS_OLD.SAPSR3.DOKHL o, tempdb..zdoku_list l where o.ID = l.ID and o.OBJECT = l.OBJECT and o.LANGU <> 'S'
select 'DUMP DOKIL no-S' as que, count(*) from BAS_OLD.SAPSR3.DOKIL o, tempdb..zdoku_list l where o.ID = l.ID and o.OBJECT = l.OBJECT and o.LANGU <> 'S'
select 'DUMP objetos con DOKIL E' as que, count(distinct o.OBJECT) from BAS_OLD.SAPSR3.DOKIL o, tempdb..zdoku_list l where o.ID = l.ID and o.OBJECT = l.OBJECT and o.LANGU = 'E'
go
/* Copia (cada tabla en su transacción; no inserta filas que ya existan) */
begin tran
insert into BAS.SAPSR3.DOKHL
  select o.* from BAS_OLD.SAPSR3.DOKHL o, tempdb..zdoku_list l
   where o.ID = l.ID and o.OBJECT = l.OBJECT and o.LANGU <> 'S'
     and not exists (select 1 from BAS.SAPSR3.DOKHL x
                      where x.ID = o.ID and x.OBJECT = o.OBJECT and x.LANGU = o.LANGU
                        and x.TYP = o.TYP and x.DOKVERSION = o.DOKVERSION)
select 'insert DOKHL' as que, @@rowcount
commit tran
go
begin tran
insert into BAS.SAPSR3.DOKIL
  select o.* from BAS_OLD.SAPSR3.DOKIL o, tempdb..zdoku_list l
   where o.ID = l.ID and o.OBJECT = l.OBJECT and o.LANGU <> 'S'
     and not exists (select 1 from BAS.SAPSR3.DOKIL x
                      where x.ID = o.ID and x.OBJECT = o.OBJECT and x.LANGU = o.LANGU
                        and x.TYP = o.TYP and x.VERSION = o.VERSION)
select 'insert DOKIL' as que, @@rowcount
commit tran
go
/* Control DESPUÉS (deben ser iguales a los del dump de arriba) */
select 'BAS DOKHL no-S' as que, count(*) from BAS.SAPSR3.DOKHL h, tempdb..zdoku_list l where h.ID = l.ID and h.OBJECT = l.OBJECT and h.LANGU <> 'S'
select 'BAS DOKIL no-S' as que, count(*) from BAS.SAPSR3.DOKIL h, tempdb..zdoku_list l where h.ID = l.ID and h.OBJECT = l.OBJECT and h.LANGU <> 'S'
select 'BAS objetos con DOKIL E' as que, count(distinct h.OBJECT) from BAS.SAPSR3.DOKIL h, tempdb..zdoku_list l where h.ID = l.ID and h.OBJECT = l.OBJECT and h.LANGU = 'E'
go
drop table tempdb..zdoku_list
go
