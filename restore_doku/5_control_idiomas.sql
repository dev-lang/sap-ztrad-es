/* ======================================================================
   Control de idiomas EN (E) y DE (D): compara BAS contra BAS_OLD (el
   dump) en las tablas de tablas_idiomas.txt. Solo lectura sobre BAS y
   BAS_OLD; usa dos tablas de trabajo chicas en tempdb y las borra al final.
   Por tabla e idioma informa:
     borradas    = en el dump y su clave ya no está en BAS
     modificadas = la clave está en las dos pero la fila no es idéntica
     nuevas      = en BAS y su clave no estaba en el dump
   y hasta 20 claves de muestra por categoría.
   - Clave: campos clave de DD03L (POSITION es NUMC, se maneja como texto).
     DOKCLU no los tiene en DD03L: va con clave fija.
   - Columna de idioma: se detecta sola (DDLANGUAGE, SPRSL, SPRAS, LANGU,
     LANGUAGE, LANG, SPRACHE).
   - Las columnas IMAGE/TEXT NO se comparan: datalength() sobre IMAGE en
     estas subconsultas hizo caer el proceso en ASE 15.7 (textsize,
     0xc0000005) y lo dejó colgado hasta reiniciar ASE. El largo se compara
     igual por PAGELG (DOKCLU) y DATALG (REPOTEXT).
   Plantilla: generar_sql.py --idiomas repite el bloque de abajo por cada
   tabla y deja la versión para correr en generado\.
   Correr con:  correr_sql.bat generado\5_control_idiomas.sql
   ====================================================================== */
set nocount on
go
set quoted_identifier on
go
select 'inicio' as paso, getdate()
go
if object_id('tempdb..zl_res') is not null drop table tempdb..zl_res
go
if object_id('tempdb..zl_mues') is not null drop table tempdb..zl_mues
go
create table tempdb..zl_res (tab varchar(30) not null, origen varchar(60) not null, lcol varchar(30) null,
  langu char(1) not null, en_bas int null, en_dump int null, borradas int null, modificadas int null, nuevas int null, nota varchar(100) null)
go
create table tempdb..zl_mues (tab varchar(30) not null, langu char(1) not null, que varchar(12) not null, clave varchar(250) null)
go
/* @@BLOQUE_INICIO@@ */
declare @t varchar(30), @orig varchar(60), @l varchar(30), @uid int, @uido int, @id int, @ido int,
        @k int, @c varchar(30), @ty int, @eq varchar(8000), @key varchar(3000), @kd varchar(3000),
        @lg char(1), @sql varchar(16000), @n int, @p varchar(4)
select @t = '@@TABLA@@', @orig = '@@ORIGEN@@'
select @uid = uid from BAS..sysusers where name = 'SAPSR3'
select @uido = uid from BAS_OLD..sysusers where name = 'SAPSR3'
select @id = id from BAS..sysobjects where name = @t and uid = @uid and type = 'U'
select @ido = id from BAS_OLD..sysobjects where name = @t and uid = @uido and type = 'U'
if @id is null or @ido is null
begin
  insert tempdb..zl_res (tab, origen, langu, nota) values (@t, @orig, '-', case when @id is null then 'no existe en BAS' else 'no existe en el dump' end)
  return
end
/* columna de idioma */
select @l = null
if exists (select 1 from BAS..syscolumns where id = @id and name = 'DDLANGUAGE') select @l = 'DDLANGUAGE'
else if exists (select 1 from BAS..syscolumns where id = @id and name = 'SPRSL') select @l = 'SPRSL'
else if exists (select 1 from BAS..syscolumns where id = @id and name = 'SPRAS') select @l = 'SPRAS'
else if exists (select 1 from BAS..syscolumns where id = @id and name = 'LANGU') select @l = 'LANGU'
else if exists (select 1 from BAS..syscolumns where id = @id and name = 'LANGUAGE') select @l = 'LANGUAGE'
else if exists (select 1 from BAS..syscolumns where id = @id and name = 'LANG') select @l = 'LANG'
else if exists (select 1 from BAS..syscolumns where id = @id and name = 'SPRACHE') select @l = 'SPRACHE'
if @l is null
begin
  insert tempdb..zl_res (tab, origen, langu, nota) values (@t, @orig, '-', 'sin columna de idioma')
  return
end
/* igualdad de fila completa */
select @eq = '', @key = '', @kd = ''
select @k = min(colid) from BAS..syscolumns where id = @id
while @k is not null
begin
  select @c = name, @ty = type from BAS..syscolumns where id = @id and colid = @k
  /* IMAGE/TEXT no se comparan: datalength() sobre IMAGE hizo caer el proceso en ASE (textsize, 0xc0000005).
     DOKCLU trae PAGELG y REPOTEXT trae DATALG, que guardan el largo. */
  if @ty not in (34, 35, 174)
    select @eq = @eq + case when @eq = '' then '' else ' and ' end + 'x."' + @c + '" = o."' + @c + '"'
  select @k = min(colid) from BAS..syscolumns where id = @id and colid > @k
end
/* clave desde DD03L (POSITION es NUMC: varchar) */
select @p = min(POSITION) from BAS.SAPSR3.DD03L where TABNAME = @t and AS4LOCAL = 'A' and AS4VERS = '0000' and KEYFLAG = 'X' and FIELDNAME not like '.%'
while @p is not null
begin
  select @c = min(FIELDNAME) from BAS.SAPSR3.DD03L where TABNAME = @t and AS4LOCAL = 'A' and AS4VERS = '0000' and KEYFLAG = 'X' and POSITION = @p
  if exists (select 1 from BAS..syscolumns where id = @id and name = @c)
    select @key = @key + case when @key = '' then '' else ' and ' end + 'x."' + @c + '" = o."' + @c + '"',
           @kd = @kd + case when @kd = '' then '' else ' + ''|'' + ' end + 'rtrim(convert(varchar(60), o."' + @c + '"))'
  select @p = min(POSITION) from BAS.SAPSR3.DD03L where TABNAME = @t and AS4LOCAL = 'A' and AS4VERS = '0000' and KEYFLAG = 'X' and FIELDNAME not like '.%' and POSITION > @p
end
/* DOKCLU no tiene los campos clave en DD03L: clave fija */
if @key = '' and @t = 'DOKCLU'
  select @key = 'x."ID" = o."ID" and x."OBJECT" = o."OBJECT" and x."LANGU" = o."LANGU" and x."TYP" = o."TYP" and x."DOKVERSION" = o."DOKVERSION" and x."PAGENO" = o."PAGENO"',
         @kd = 'rtrim(o."ID") + ''|'' + rtrim(o."OBJECT") + ''|'' + rtrim(o."LANGU") + ''|'' + rtrim(o."TYP") + ''|'' + rtrim(o."DOKVERSION") + ''|'' + rtrim(convert(varchar(10), o."PAGENO"))'
if @key = ''
begin
  insert tempdb..zl_res (tab, origen, lcol, langu, nota) values (@t, @orig, @l, '-', 'sin clave en DD03L')
  return
end
select @lg = 'E'
while @lg is not null
begin
  insert tempdb..zl_res (tab, origen, lcol, langu) values (@t, @orig, @l, @lg)
  select @sql = 'update tempdb..zl_res set '
    + 'en_bas = (select count(*) from BAS.SAPSR3.' + @t + ' o where o."' + @l + '" = ''' + @lg + '''), '
    + 'en_dump = (select count(*) from BAS_OLD.SAPSR3.' + @t + ' o where o."' + @l + '" = ''' + @lg + '''), '
    + 'borradas = (select count(*) from BAS_OLD.SAPSR3.' + @t + ' o where o."' + @l + '" = ''' + @lg + ''' and not exists (select 1 from BAS.SAPSR3.' + @t + ' x where ' + @key + ')), '
    + 'modificadas = (select count(*) from BAS_OLD.SAPSR3.' + @t + ' o where o."' + @l + '" = ''' + @lg + ''' and exists (select 1 from BAS.SAPSR3.' + @t + ' x where ' + @key + ') and not exists (select 1 from BAS.SAPSR3.' + @t + ' x where ' + @eq + ')), '
    + 'nuevas = (select count(*) from BAS.SAPSR3.' + @t + ' o where o."' + @l + '" = ''' + @lg + ''' and not exists (select 1 from BAS_OLD.SAPSR3.' + @t + ' x where ' + @key + ')) '
    + 'where tab = ''' + @t + ''' and langu = ''' + @lg + ''''
  exec (@sql)
  /* muestras (hasta 20 claves por categoría) */
  select @n = borradas from tempdb..zl_res where tab = @t and langu = @lg
  if @n > 0
    exec ('set rowcount 20 insert tempdb..zl_mues select ''' + @t + ''', ''' + @lg + ''', ''borrada'', ' + @kd + ' from BAS_OLD.SAPSR3.' + @t + ' o where o."' + @l + '" = ''' + @lg + ''' and not exists (select 1 from BAS.SAPSR3.' + @t + ' x where ' + @key + ') set rowcount 0')
  select @n = modificadas from tempdb..zl_res where tab = @t and langu = @lg
  if @n > 0
    exec ('set rowcount 20 insert tempdb..zl_mues select ''' + @t + ''', ''' + @lg + ''', ''modificada'', ' + @kd + ' from BAS_OLD.SAPSR3.' + @t + ' o where o."' + @l + '" = ''' + @lg + ''' and exists (select 1 from BAS.SAPSR3.' + @t + ' x where ' + @key + ') and not exists (select 1 from BAS.SAPSR3.' + @t + ' x where ' + @eq + ') set rowcount 0')
  select @n = nuevas from tempdb..zl_res where tab = @t and langu = @lg
  if @n > 0
    exec ('set rowcount 20 insert tempdb..zl_mues select ''' + @t + ''', ''' + @lg + ''', ''nueva'', ' + @kd + ' from BAS.SAPSR3.' + @t + ' o where o."' + @l + '" = ''' + @lg + ''' and not exists (select 1 from BAS_OLD.SAPSR3.' + @t + ' x where ' + @key + ') set rowcount 0')
  select @lg = case @lg when 'E' then 'D' else null end
end
select tab, langu, en_bas, en_dump, borradas, modificadas, nuevas, getdate() as hora from tempdb..zl_res where tab = @t
go
/* @@BLOQUE_FIN@@ */
select 'fin' as paso, getdate()
go
select 'RESUMEN' as r, tab, langu, lcol, en_bas, en_dump, borradas, modificadas, nuevas, origen, nota from tempdb..zl_res order by tab, langu
go
select 'TOTAL' as r, langu, sum(borradas) as borradas, sum(modificadas) as modificadas, sum(nuevas) as nuevas from tempdb..zl_res where langu in ('E', 'D') group by langu
go
select 'MUESTRAS' as r, tab, langu, que, clave from tempdb..zl_mues order by tab, langu, que, clave
go
drop table tempdb..zl_mues
go
drop table tempdb..zl_res
go
