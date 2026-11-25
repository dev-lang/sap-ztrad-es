/* ======================================================================
   4_control_s_vs_e.sql - Despues del paso 1: cuantas filas S quedaron
   distintas de su E (misma clave). SOLO LECTURA. Claves desde DD03L.
   No toca REPOTEXT (IMAGE). Tabla de trabajo chica en tempdb.
   Correr con:  correr_sql.bat sql\04_control_s_vs_e.sql
   ====================================================================== */
set nocount on
go
set quoted_identifier on
go
select 'inicio', getdate()
go
if object_id('tempdb..zc_res') is not null drop table tempdb..zc_res
go
create table tempdb..zc_res (tab varchar(30), filas_s int, s_sin_e int, s_distinto_e int, clave varchar(2000))
go
declare @t varchar(30), @l varchar(30), @p varchar(4), @f varchar(30), @j varchar(2000), @sql varchar(6000)
select @t = 'T100', @l = 'SPRSL', @j = '', @p = ''
while 1 = 1
begin
  select @p = min(POSITION) from BAS.SAPSR3.DD03L noholdlock
   where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG = 'X' and POSITION > @p and FIELDNAME not like '.%' and FIELDNAME <> @l
  if @p is null break
  select @f = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and POSITION = @p
  select @j = @j + ' and s."' + @f + '" = e."' + @f + '"'
end
select @sql = 'insert tempdb..zc_res select ''' + @t + ''', '
 + '(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock where s."' + @l + '" = ''S''), '
 + '(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock where s."' + @l + '" = ''S'' and not exists (select 1 from BAS.SAPSR3."' + @t + '" e noholdlock where e."' + @l + '" = ''E''' + @j + ')), '
 + '(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and (s."TEXT" <> e."TEXT")), '
 + '''' + @j + ''''
exec (@sql)
go
declare @t varchar(30), @l varchar(30), @p varchar(4), @f varchar(30), @j varchar(2000), @sql varchar(6000)
select @t = 'TSTCT', @l = 'SPRSL', @j = '', @p = ''
while 1 = 1
begin
  select @p = min(POSITION) from BAS.SAPSR3.DD03L noholdlock
   where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG = 'X' and POSITION > @p and FIELDNAME not like '.%' and FIELDNAME <> @l
  if @p is null break
  select @f = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and POSITION = @p
  select @j = @j + ' and s."' + @f + '" = e."' + @f + '"'
end
select @sql = 'insert tempdb..zc_res select ''' + @t + ''', '
 + '(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock where s."' + @l + '" = ''S''), '
 + '(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock where s."' + @l + '" = ''S'' and not exists (select 1 from BAS.SAPSR3."' + @t + '" e noholdlock where e."' + @l + '" = ''E''' + @j + ')), '
 + '(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and (s."TTEXT" <> e."TTEXT")), '
 + '''' + @j + ''''
exec (@sql)
go
declare @t varchar(30), @l varchar(30), @p varchar(4), @f varchar(30), @j varchar(2000), @sql varchar(6000)
select @t = 'DD01T', @l = 'DDLANGUAGE', @j = '', @p = ''
while 1 = 1
begin
  select @p = min(POSITION) from BAS.SAPSR3.DD03L noholdlock
   where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG = 'X' and POSITION > @p and FIELDNAME not like '.%' and FIELDNAME <> @l
  if @p is null break
  select @f = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and POSITION = @p
  select @j = @j + ' and s."' + @f + '" = e."' + @f + '"'
end
select @sql = 'insert tempdb..zc_res select ''' + @t + ''', '
 + '(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock where s."' + @l + '" = ''S''), '
 + '(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock where s."' + @l + '" = ''S'' and not exists (select 1 from BAS.SAPSR3."' + @t + '" e noholdlock where e."' + @l + '" = ''E''' + @j + ')), '
 + '(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and (s."DDTEXT" <> e."DDTEXT")), '
 + '''' + @j + ''''
exec (@sql)
go
declare @t varchar(30), @l varchar(30), @p varchar(4), @f varchar(30), @j varchar(2000), @sql varchar(6000)
select @t = 'DD02T', @l = 'DDLANGUAGE', @j = '', @p = ''
while 1 = 1
begin
  select @p = min(POSITION) from BAS.SAPSR3.DD03L noholdlock
   where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG = 'X' and POSITION > @p and FIELDNAME not like '.%' and FIELDNAME <> @l
  if @p is null break
  select @f = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and POSITION = @p
  select @j = @j + ' and s."' + @f + '" = e."' + @f + '"'
end
select @sql = 'insert tempdb..zc_res select ''' + @t + ''', '
 + '(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock where s."' + @l + '" = ''S''), '
 + '(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock where s."' + @l + '" = ''S'' and not exists (select 1 from BAS.SAPSR3."' + @t + '" e noholdlock where e."' + @l + '" = ''E''' + @j + ')), '
 + '(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and (s."DDTEXT" <> e."DDTEXT")), '
 + '''' + @j + ''''
exec (@sql)
go
declare @t varchar(30), @l varchar(30), @p varchar(4), @f varchar(30), @j varchar(2000), @sql varchar(6000)
select @t = 'DD04T', @l = 'DDLANGUAGE', @j = '', @p = ''
while 1 = 1
begin
  select @p = min(POSITION) from BAS.SAPSR3.DD03L noholdlock
   where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG = 'X' and POSITION > @p and FIELDNAME not like '.%' and FIELDNAME <> @l
  if @p is null break
  select @f = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and POSITION = @p
  select @j = @j + ' and s."' + @f + '" = e."' + @f + '"'
end
select @sql = 'insert tempdb..zc_res select ''' + @t + ''', '
 + '(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock where s."' + @l + '" = ''S''), '
 + '(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock where s."' + @l + '" = ''S'' and not exists (select 1 from BAS.SAPSR3."' + @t + '" e noholdlock where e."' + @l + '" = ''E''' + @j + ')), '
 + '(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and (s."DDTEXT" <> e."DDTEXT" or s."REPTEXT" <> e."REPTEXT" or s."SCRTEXT_S" <> e."SCRTEXT_S" or s."SCRTEXT_M" <> e."SCRTEXT_M" or s."SCRTEXT_L" <> e."SCRTEXT_L")), '
 + '''' + @j + ''''
exec (@sql)
go
declare @t varchar(30), @l varchar(30), @p varchar(4), @f varchar(30), @j varchar(2000), @sql varchar(6000)
select @t = 'DD07T', @l = 'DDLANGUAGE', @j = '', @p = ''
while 1 = 1
begin
  select @p = min(POSITION) from BAS.SAPSR3.DD03L noholdlock
   where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG = 'X' and POSITION > @p and FIELDNAME not like '.%' and FIELDNAME <> @l
  if @p is null break
  select @f = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and POSITION = @p
  select @j = @j + ' and s."' + @f + '" = e."' + @f + '"'
end
select @sql = 'insert tempdb..zc_res select ''' + @t + ''', '
 + '(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock where s."' + @l + '" = ''S''), '
 + '(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock where s."' + @l + '" = ''S'' and not exists (select 1 from BAS.SAPSR3."' + @t + '" e noholdlock where e."' + @l + '" = ''E''' + @j + ')), '
 + '(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and (s."DDTEXT" <> e."DDTEXT")), '
 + '''' + @j + ''''
exec (@sql)
go
declare @t varchar(30), @l varchar(30), @p varchar(4), @f varchar(30), @j varchar(2000), @sql varchar(6000)
select @t = 'DD30T', @l = 'DDLANGUAGE', @j = '', @p = ''
while 1 = 1
begin
  select @p = min(POSITION) from BAS.SAPSR3.DD03L noholdlock
   where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG = 'X' and POSITION > @p and FIELDNAME not like '.%' and FIELDNAME <> @l
  if @p is null break
  select @f = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and POSITION = @p
  select @j = @j + ' and s."' + @f + '" = e."' + @f + '"'
end
select @sql = 'insert tempdb..zc_res select ''' + @t + ''', '
 + '(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock where s."' + @l + '" = ''S''), '
 + '(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock where s."' + @l + '" = ''S'' and not exists (select 1 from BAS.SAPSR3."' + @t + '" e noholdlock where e."' + @l + '" = ''E''' + @j + ')), '
 + '(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and (s."DDTEXT" <> e."DDTEXT")), '
 + '''' + @j + ''''
exec (@sql)
go
declare @t varchar(30), @l varchar(30), @p varchar(4), @f varchar(30), @j varchar(2000), @sql varchar(6000)
select @t = 'D020T', @l = 'LANG', @j = '', @p = ''
while 1 = 1
begin
  select @p = min(POSITION) from BAS.SAPSR3.DD03L noholdlock
   where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG = 'X' and POSITION > @p and FIELDNAME not like '.%' and FIELDNAME <> @l
  if @p is null break
  select @f = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and POSITION = @p
  select @j = @j + ' and s."' + @f + '" = e."' + @f + '"'
end
select @sql = 'insert tempdb..zc_res select ''' + @t + ''', '
 + '(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock where s."' + @l + '" = ''S''), '
 + '(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock where s."' + @l + '" = ''S'' and not exists (select 1 from BAS.SAPSR3."' + @t + '" e noholdlock where e."' + @l + '" = ''E''' + @j + ')), '
 + '(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and (s."DTXT" <> e."DTXT")), '
 + '''' + @j + ''''
exec (@sql)
go
declare @t varchar(30), @l varchar(30), @p varchar(4), @f varchar(30), @j varchar(2000), @sql varchar(6000)
select @t = 'D021T', @l = 'LANG', @j = '', @p = ''
while 1 = 1
begin
  select @p = min(POSITION) from BAS.SAPSR3.DD03L noholdlock
   where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG = 'X' and POSITION > @p and FIELDNAME not like '.%' and FIELDNAME <> @l
  if @p is null break
  select @f = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and POSITION = @p
  select @j = @j + ' and s."' + @f + '" = e."' + @f + '"'
end
select @sql = 'insert tempdb..zc_res select ''' + @t + ''', '
 + '(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock where s."' + @l + '" = ''S''), '
 + '(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock where s."' + @l + '" = ''S'' and not exists (select 1 from BAS.SAPSR3."' + @t + '" e noholdlock where e."' + @l + '" = ''E''' + @j + ')), '
 + '(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and (s."DTXT" <> e."DTXT")), '
 + '''' + @j + ''''
exec (@sql)
go
declare @t varchar(30), @l varchar(30), @p varchar(4), @f varchar(30), @j varchar(2000), @sql varchar(6000)
select @t = 'RSMPTEXTS', @l = 'SPRSL', @j = '', @p = ''
while 1 = 1
begin
  select @p = min(POSITION) from BAS.SAPSR3.DD03L noholdlock
   where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG = 'X' and POSITION > @p and FIELDNAME not like '.%' and FIELDNAME <> @l
  if @p is null break
  select @f = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and POSITION = @p
  select @j = @j + ' and s."' + @f + '" = e."' + @f + '"'
end
select @sql = 'insert tempdb..zc_res select ''' + @t + ''', '
 + '(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock where s."' + @l + '" = ''S''), '
 + '(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock where s."' + @l + '" = ''S'' and not exists (select 1 from BAS.SAPSR3."' + @t + '" e noholdlock where e."' + @l + '" = ''E''' + @j + ')), '
 + '(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and (s."TEXT" <> e."TEXT")), '
 + '''' + @j + ''''
exec (@sql)
go
declare @t varchar(30), @l varchar(30), @p varchar(4), @f varchar(30), @j varchar(2000), @sql varchar(6000)
select @t = 'CUS_IMGACT', @l = 'SPRAS', @j = '', @p = ''
while 1 = 1
begin
  select @p = min(POSITION) from BAS.SAPSR3.DD03L noholdlock
   where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG = 'X' and POSITION > @p and FIELDNAME not like '.%' and FIELDNAME <> @l
  if @p is null break
  select @f = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and POSITION = @p
  select @j = @j + ' and s."' + @f + '" = e."' + @f + '"'
end
select @sql = 'insert tempdb..zc_res select ''' + @t + ''', '
 + '(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock where s."' + @l + '" = ''S''), '
 + '(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock where s."' + @l + '" = ''S'' and not exists (select 1 from BAS.SAPSR3."' + @t + '" e noholdlock where e."' + @l + '" = ''E''' + @j + ')), '
 + '(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and (s."TEXT" <> e."TEXT")), '
 + '''' + @j + ''''
exec (@sql)
go
declare @t varchar(30), @l varchar(30), @p varchar(4), @f varchar(30), @j varchar(2000), @sql varchar(6000)
select @t = 'TNODEIMGT', @l = 'SPRAS', @j = '', @p = ''
while 1 = 1
begin
  select @p = min(POSITION) from BAS.SAPSR3.DD03L noholdlock
   where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG = 'X' and POSITION > @p and FIELDNAME not like '.%' and FIELDNAME <> @l
  if @p is null break
  select @f = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and POSITION = @p
  select @j = @j + ' and s."' + @f + '" = e."' + @f + '"'
end
select @sql = 'insert tempdb..zc_res select ''' + @t + ''', '
 + '(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock where s."' + @l + '" = ''S''), '
 + '(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock where s."' + @l + '" = ''S'' and not exists (select 1 from BAS.SAPSR3."' + @t + '" e noholdlock where e."' + @l + '" = ''E''' + @j + ')), '
 + '(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and (s."TEXT" <> e."TEXT")), '
 + '''' + @j + ''''
exec (@sql)
go
print '=== Filas S, S sin fila E, y S distinto de E por tabla ==='
select tab, filas_s, s_sin_e, s_distinto_e from tempdb..zc_res order by tab
go
select tab, clave from tempdb..zc_res order by tab
go
drop table tempdb..zc_res
go
select 'fin', getdate()
go
