/* 10_control_multi.sql - SOLO LECTURA. Tablas de customizing que cargo ZTRAD_MULTI
   (y TCURT/T003T/T004G/TAMLAY*): por tabla, filas S, S sin E y S distinto de E en
   cualquier campo de texto, mas el detalle campo por campo:
     #TABLA#clave#CAMPO#S|E#texto     y   #RESUMEN#TABLA#filas_s#s_sin_e#s_distinto_e
   Claves, idioma y campos de texto salen de DD03L.  Correr: correr_sql.bat sql\10_control_multi.sql */
set nocount on
go
set quoted_identifier on
go
select 'inicio', getdate()
go
declare @t varchar(30), @l varchar(30), @p varchar(4), @f varchar(30), @j varchar(2000), @k varchar(2000), @d varchar(3000), @sql varchar(8000)
select @t = 'ANKT', @j = '', @k = '', @d = '', @p = '', @l = null
if object_id('BAS.SAPSR3.ANKT') is null
begin
  select '#ANKT#NO_ES_TABLA_TRANSPARENTE'
end
else
begin
  select @l = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG = 'X' and DATATYPE = 'LANG'
  if @l is null select '#ANKT#SIN_CAMPO_IDIOMA'
  else
  begin
    while 1 = 1
    begin
      select @p = min(POSITION) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG = 'X' and POSITION > @p and FIELDNAME not like '.%' and FIELDNAME <> @l
      if @p is null break
      select @f = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and POSITION = @p
      select @j = @j + ' and s."' + @f + '" = e."' + @f + '"'
      select @k = @k + case when @k = '' then '' else ' + ''|'' + ' end + 'isnull(rtrim(convert(varchar(100),s."' + @f + '")),'''')'
    end
    select @p = ''
    while 1 = 1
    begin
      select @p = min(POSITION) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG <> 'X' and INTTYPE = 'C' and POSITION > @p and FIELDNAME not like '.%'
      if @p is null break
      select @f = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and POSITION = @p
      select @d = @d + case when @d = '' then '' else ' or ' end + 's."' + @f + '" <> e."' + @f + '"'
      select @sql = 'select convert(varchar(290), ''#' + @t + '#'' + ' + @k + ' + ''#' + @f + '#S#'' + isnull(rtrim(s."' + @f + '"),'''')) k from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and s."' + @f + '" <> e."' + @f + '"'
       + ' union all select convert(varchar(290), ''#' + @t + '#'' + ' + @k + ' + ''#' + @f + '#E#'' + isnull(rtrim(e."' + @f + '"),'''')) k from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and s."' + @f + '" <> e."' + @f + '"'
      exec (@sql)
    end
    if @d = '' select @d = '1 = 0'
    select @sql = 'select ''#RESUMEN#' + @t + '#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock where s."' + @l + '" = ''S''))'
     + ' + ''#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock where s."' + @l + '" = ''S'' and not exists (select 1 from BAS.SAPSR3."' + @t + '" e noholdlock where e."' + @l + '" = ''E''' + @j + ')))'
     + ' + ''#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and (' + @d + ')))'
    exec (@sql)
  end
end
go
declare @t varchar(30), @l varchar(30), @p varchar(4), @f varchar(30), @j varchar(2000), @k varchar(2000), @d varchar(3000), @sql varchar(8000)
select @t = 'SETCLST', @j = '', @k = '', @d = '', @p = '', @l = null
if object_id('BAS.SAPSR3.SETCLST') is null
begin
  select '#SETCLST#NO_ES_TABLA_TRANSPARENTE'
end
else
begin
  select @l = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG = 'X' and DATATYPE = 'LANG'
  if @l is null select '#SETCLST#SIN_CAMPO_IDIOMA'
  else
  begin
    while 1 = 1
    begin
      select @p = min(POSITION) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG = 'X' and POSITION > @p and FIELDNAME not like '.%' and FIELDNAME <> @l
      if @p is null break
      select @f = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and POSITION = @p
      select @j = @j + ' and s."' + @f + '" = e."' + @f + '"'
      select @k = @k + case when @k = '' then '' else ' + ''|'' + ' end + 'isnull(rtrim(convert(varchar(100),s."' + @f + '")),'''')'
    end
    select @p = ''
    while 1 = 1
    begin
      select @p = min(POSITION) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG <> 'X' and INTTYPE = 'C' and POSITION > @p and FIELDNAME not like '.%'
      if @p is null break
      select @f = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and POSITION = @p
      select @d = @d + case when @d = '' then '' else ' or ' end + 's."' + @f + '" <> e."' + @f + '"'
      select @sql = 'select convert(varchar(290), ''#' + @t + '#'' + ' + @k + ' + ''#' + @f + '#S#'' + isnull(rtrim(s."' + @f + '"),'''')) k from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and s."' + @f + '" <> e."' + @f + '"'
       + ' union all select convert(varchar(290), ''#' + @t + '#'' + ' + @k + ' + ''#' + @f + '#E#'' + isnull(rtrim(e."' + @f + '"),'''')) k from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and s."' + @f + '" <> e."' + @f + '"'
      exec (@sql)
    end
    if @d = '' select @d = '1 = 0'
    select @sql = 'select ''#RESUMEN#' + @t + '#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock where s."' + @l + '" = ''S''))'
     + ' + ''#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock where s."' + @l + '" = ''S'' and not exists (select 1 from BAS.SAPSR3."' + @t + '" e noholdlock where e."' + @l + '" = ''E''' + @j + ')))'
     + ' + ''#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and (' + @d + ')))'
    exec (@sql)
  end
end
go
declare @t varchar(30), @l varchar(30), @p varchar(4), @f varchar(30), @j varchar(2000), @k varchar(2000), @d varchar(3000), @sql varchar(8000)
select @t = 'SETEXITST', @j = '', @k = '', @d = '', @p = '', @l = null
if object_id('BAS.SAPSR3.SETEXITST') is null
begin
  select '#SETEXITST#NO_ES_TABLA_TRANSPARENTE'
end
else
begin
  select @l = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG = 'X' and DATATYPE = 'LANG'
  if @l is null select '#SETEXITST#SIN_CAMPO_IDIOMA'
  else
  begin
    while 1 = 1
    begin
      select @p = min(POSITION) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG = 'X' and POSITION > @p and FIELDNAME not like '.%' and FIELDNAME <> @l
      if @p is null break
      select @f = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and POSITION = @p
      select @j = @j + ' and s."' + @f + '" = e."' + @f + '"'
      select @k = @k + case when @k = '' then '' else ' + ''|'' + ' end + 'isnull(rtrim(convert(varchar(100),s."' + @f + '")),'''')'
    end
    select @p = ''
    while 1 = 1
    begin
      select @p = min(POSITION) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG <> 'X' and INTTYPE = 'C' and POSITION > @p and FIELDNAME not like '.%'
      if @p is null break
      select @f = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and POSITION = @p
      select @d = @d + case when @d = '' then '' else ' or ' end + 's."' + @f + '" <> e."' + @f + '"'
      select @sql = 'select convert(varchar(290), ''#' + @t + '#'' + ' + @k + ' + ''#' + @f + '#S#'' + isnull(rtrim(s."' + @f + '"),'''')) k from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and s."' + @f + '" <> e."' + @f + '"'
       + ' union all select convert(varchar(290), ''#' + @t + '#'' + ' + @k + ' + ''#' + @f + '#E#'' + isnull(rtrim(e."' + @f + '"),'''')) k from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and s."' + @f + '" <> e."' + @f + '"'
      exec (@sql)
    end
    if @d = '' select @d = '1 = 0'
    select @sql = 'select ''#RESUMEN#' + @t + '#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock where s."' + @l + '" = ''S''))'
     + ' + ''#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock where s."' + @l + '" = ''S'' and not exists (select 1 from BAS.SAPSR3."' + @t + '" e noholdlock where e."' + @l + '" = ''E''' + @j + ')))'
     + ' + ''#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and (' + @d + ')))'
    exec (@sql)
  end
end
go
declare @t varchar(30), @l varchar(30), @p varchar(4), @f varchar(30), @j varchar(2000), @k varchar(2000), @d varchar(3000), @sql varchar(8000)
select @t = 'SETHEADERT', @j = '', @k = '', @d = '', @p = '', @l = null
if object_id('BAS.SAPSR3.SETHEADERT') is null
begin
  select '#SETHEADERT#NO_ES_TABLA_TRANSPARENTE'
end
else
begin
  select @l = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG = 'X' and DATATYPE = 'LANG'
  if @l is null select '#SETHEADERT#SIN_CAMPO_IDIOMA'
  else
  begin
    while 1 = 1
    begin
      select @p = min(POSITION) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG = 'X' and POSITION > @p and FIELDNAME not like '.%' and FIELDNAME <> @l
      if @p is null break
      select @f = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and POSITION = @p
      select @j = @j + ' and s."' + @f + '" = e."' + @f + '"'
      select @k = @k + case when @k = '' then '' else ' + ''|'' + ' end + 'isnull(rtrim(convert(varchar(100),s."' + @f + '")),'''')'
    end
    select @p = ''
    while 1 = 1
    begin
      select @p = min(POSITION) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG <> 'X' and INTTYPE = 'C' and POSITION > @p and FIELDNAME not like '.%'
      if @p is null break
      select @f = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and POSITION = @p
      select @d = @d + case when @d = '' then '' else ' or ' end + 's."' + @f + '" <> e."' + @f + '"'
      select @sql = 'select convert(varchar(290), ''#' + @t + '#'' + ' + @k + ' + ''#' + @f + '#S#'' + isnull(rtrim(s."' + @f + '"),'''')) k from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and s."' + @f + '" <> e."' + @f + '"'
       + ' union all select convert(varchar(290), ''#' + @t + '#'' + ' + @k + ' + ''#' + @f + '#E#'' + isnull(rtrim(e."' + @f + '"),'''')) k from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and s."' + @f + '" <> e."' + @f + '"'
      exec (@sql)
    end
    if @d = '' select @d = '1 = 0'
    select @sql = 'select ''#RESUMEN#' + @t + '#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock where s."' + @l + '" = ''S''))'
     + ' + ''#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock where s."' + @l + '" = ''S'' and not exists (select 1 from BAS.SAPSR3."' + @t + '" e noholdlock where e."' + @l + '" = ''E''' + @j + ')))'
     + ' + ''#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and (' + @d + ')))'
    exec (@sql)
  end
end
go
declare @t varchar(30), @l varchar(30), @p varchar(4), @f varchar(30), @j varchar(2000), @k varchar(2000), @d varchar(3000), @sql varchar(8000)
select @t = 'SETLINET', @j = '', @k = '', @d = '', @p = '', @l = null
if object_id('BAS.SAPSR3.SETLINET') is null
begin
  select '#SETLINET#NO_ES_TABLA_TRANSPARENTE'
end
else
begin
  select @l = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG = 'X' and DATATYPE = 'LANG'
  if @l is null select '#SETLINET#SIN_CAMPO_IDIOMA'
  else
  begin
    while 1 = 1
    begin
      select @p = min(POSITION) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG = 'X' and POSITION > @p and FIELDNAME not like '.%' and FIELDNAME <> @l
      if @p is null break
      select @f = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and POSITION = @p
      select @j = @j + ' and s."' + @f + '" = e."' + @f + '"'
      select @k = @k + case when @k = '' then '' else ' + ''|'' + ' end + 'isnull(rtrim(convert(varchar(100),s."' + @f + '")),'''')'
    end
    select @p = ''
    while 1 = 1
    begin
      select @p = min(POSITION) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG <> 'X' and INTTYPE = 'C' and POSITION > @p and FIELDNAME not like '.%'
      if @p is null break
      select @f = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and POSITION = @p
      select @d = @d + case when @d = '' then '' else ' or ' end + 's."' + @f + '" <> e."' + @f + '"'
      select @sql = 'select convert(varchar(290), ''#' + @t + '#'' + ' + @k + ' + ''#' + @f + '#S#'' + isnull(rtrim(s."' + @f + '"),'''')) k from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and s."' + @f + '" <> e."' + @f + '"'
       + ' union all select convert(varchar(290), ''#' + @t + '#'' + ' + @k + ' + ''#' + @f + '#E#'' + isnull(rtrim(e."' + @f + '"),'''')) k from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and s."' + @f + '" <> e."' + @f + '"'
      exec (@sql)
    end
    if @d = '' select @d = '1 = 0'
    select @sql = 'select ''#RESUMEN#' + @t + '#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock where s."' + @l + '" = ''S''))'
     + ' + ''#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock where s."' + @l + '" = ''S'' and not exists (select 1 from BAS.SAPSR3."' + @t + '" e noholdlock where e."' + @l + '" = ''E''' + @j + ')))'
     + ' + ''#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and (' + @d + ')))'
    exec (@sql)
  end
end
go
declare @t varchar(30), @l varchar(30), @p varchar(4), @f varchar(30), @j varchar(2000), @k varchar(2000), @d varchar(3000), @sql varchar(8000)
select @t = 'T003T', @j = '', @k = '', @d = '', @p = '', @l = null
if object_id('BAS.SAPSR3.T003T') is null
begin
  select '#T003T#NO_ES_TABLA_TRANSPARENTE'
end
else
begin
  select @l = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG = 'X' and DATATYPE = 'LANG'
  if @l is null select '#T003T#SIN_CAMPO_IDIOMA'
  else
  begin
    while 1 = 1
    begin
      select @p = min(POSITION) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG = 'X' and POSITION > @p and FIELDNAME not like '.%' and FIELDNAME <> @l
      if @p is null break
      select @f = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and POSITION = @p
      select @j = @j + ' and s."' + @f + '" = e."' + @f + '"'
      select @k = @k + case when @k = '' then '' else ' + ''|'' + ' end + 'isnull(rtrim(convert(varchar(100),s."' + @f + '")),'''')'
    end
    select @p = ''
    while 1 = 1
    begin
      select @p = min(POSITION) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG <> 'X' and INTTYPE = 'C' and POSITION > @p and FIELDNAME not like '.%'
      if @p is null break
      select @f = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and POSITION = @p
      select @d = @d + case when @d = '' then '' else ' or ' end + 's."' + @f + '" <> e."' + @f + '"'
      select @sql = 'select convert(varchar(290), ''#' + @t + '#'' + ' + @k + ' + ''#' + @f + '#S#'' + isnull(rtrim(s."' + @f + '"),'''')) k from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and s."' + @f + '" <> e."' + @f + '"'
       + ' union all select convert(varchar(290), ''#' + @t + '#'' + ' + @k + ' + ''#' + @f + '#E#'' + isnull(rtrim(e."' + @f + '"),'''')) k from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and s."' + @f + '" <> e."' + @f + '"'
      exec (@sql)
    end
    if @d = '' select @d = '1 = 0'
    select @sql = 'select ''#RESUMEN#' + @t + '#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock where s."' + @l + '" = ''S''))'
     + ' + ''#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock where s."' + @l + '" = ''S'' and not exists (select 1 from BAS.SAPSR3."' + @t + '" e noholdlock where e."' + @l + '" = ''E''' + @j + ')))'
     + ' + ''#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and (' + @d + ')))'
    exec (@sql)
  end
end
go
declare @t varchar(30), @l varchar(30), @p varchar(4), @f varchar(30), @j varchar(2000), @k varchar(2000), @d varchar(3000), @sql varchar(8000)
select @t = 'T004G', @j = '', @k = '', @d = '', @p = '', @l = null
if object_id('BAS.SAPSR3.T004G') is null
begin
  select '#T004G#NO_ES_TABLA_TRANSPARENTE'
end
else
begin
  select @l = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG = 'X' and DATATYPE = 'LANG'
  if @l is null select '#T004G#SIN_CAMPO_IDIOMA'
  else
  begin
    while 1 = 1
    begin
      select @p = min(POSITION) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG = 'X' and POSITION > @p and FIELDNAME not like '.%' and FIELDNAME <> @l
      if @p is null break
      select @f = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and POSITION = @p
      select @j = @j + ' and s."' + @f + '" = e."' + @f + '"'
      select @k = @k + case when @k = '' then '' else ' + ''|'' + ' end + 'isnull(rtrim(convert(varchar(100),s."' + @f + '")),'''')'
    end
    select @p = ''
    while 1 = 1
    begin
      select @p = min(POSITION) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG <> 'X' and INTTYPE = 'C' and POSITION > @p and FIELDNAME not like '.%'
      if @p is null break
      select @f = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and POSITION = @p
      select @d = @d + case when @d = '' then '' else ' or ' end + 's."' + @f + '" <> e."' + @f + '"'
      select @sql = 'select convert(varchar(290), ''#' + @t + '#'' + ' + @k + ' + ''#' + @f + '#S#'' + isnull(rtrim(s."' + @f + '"),'''')) k from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and s."' + @f + '" <> e."' + @f + '"'
       + ' union all select convert(varchar(290), ''#' + @t + '#'' + ' + @k + ' + ''#' + @f + '#E#'' + isnull(rtrim(e."' + @f + '"),'''')) k from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and s."' + @f + '" <> e."' + @f + '"'
      exec (@sql)
    end
    if @d = '' select @d = '1 = 0'
    select @sql = 'select ''#RESUMEN#' + @t + '#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock where s."' + @l + '" = ''S''))'
     + ' + ''#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock where s."' + @l + '" = ''S'' and not exists (select 1 from BAS.SAPSR3."' + @t + '" e noholdlock where e."' + @l + '" = ''E''' + @j + ')))'
     + ' + ''#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and (' + @d + ')))'
    exec (@sql)
  end
end
go
declare @t varchar(30), @l varchar(30), @p varchar(4), @f varchar(30), @j varchar(2000), @k varchar(2000), @d varchar(3000), @sql varchar(8000)
select @t = 'T005T', @j = '', @k = '', @d = '', @p = '', @l = null
if object_id('BAS.SAPSR3.T005T') is null
begin
  select '#T005T#NO_ES_TABLA_TRANSPARENTE'
end
else
begin
  select @l = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG = 'X' and DATATYPE = 'LANG'
  if @l is null select '#T005T#SIN_CAMPO_IDIOMA'
  else
  begin
    while 1 = 1
    begin
      select @p = min(POSITION) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG = 'X' and POSITION > @p and FIELDNAME not like '.%' and FIELDNAME <> @l
      if @p is null break
      select @f = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and POSITION = @p
      select @j = @j + ' and s."' + @f + '" = e."' + @f + '"'
      select @k = @k + case when @k = '' then '' else ' + ''|'' + ' end + 'isnull(rtrim(convert(varchar(100),s."' + @f + '")),'''')'
    end
    select @p = ''
    while 1 = 1
    begin
      select @p = min(POSITION) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG <> 'X' and INTTYPE = 'C' and POSITION > @p and FIELDNAME not like '.%'
      if @p is null break
      select @f = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and POSITION = @p
      select @d = @d + case when @d = '' then '' else ' or ' end + 's."' + @f + '" <> e."' + @f + '"'
      select @sql = 'select convert(varchar(290), ''#' + @t + '#'' + ' + @k + ' + ''#' + @f + '#S#'' + isnull(rtrim(s."' + @f + '"),'''')) k from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and s."' + @f + '" <> e."' + @f + '"'
       + ' union all select convert(varchar(290), ''#' + @t + '#'' + ' + @k + ' + ''#' + @f + '#E#'' + isnull(rtrim(e."' + @f + '"),'''')) k from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and s."' + @f + '" <> e."' + @f + '"'
      exec (@sql)
    end
    if @d = '' select @d = '1 = 0'
    select @sql = 'select ''#RESUMEN#' + @t + '#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock where s."' + @l + '" = ''S''))'
     + ' + ''#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock where s."' + @l + '" = ''S'' and not exists (select 1 from BAS.SAPSR3."' + @t + '" e noholdlock where e."' + @l + '" = ''E''' + @j + ')))'
     + ' + ''#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and (' + @d + ')))'
    exec (@sql)
  end
end
go
declare @t varchar(30), @l varchar(30), @p varchar(4), @f varchar(30), @j varchar(2000), @k varchar(2000), @d varchar(3000), @sql varchar(8000)
select @t = 'T006T', @j = '', @k = '', @d = '', @p = '', @l = null
if object_id('BAS.SAPSR3.T006T') is null
begin
  select '#T006T#NO_ES_TABLA_TRANSPARENTE'
end
else
begin
  select @l = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG = 'X' and DATATYPE = 'LANG'
  if @l is null select '#T006T#SIN_CAMPO_IDIOMA'
  else
  begin
    while 1 = 1
    begin
      select @p = min(POSITION) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG = 'X' and POSITION > @p and FIELDNAME not like '.%' and FIELDNAME <> @l
      if @p is null break
      select @f = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and POSITION = @p
      select @j = @j + ' and s."' + @f + '" = e."' + @f + '"'
      select @k = @k + case when @k = '' then '' else ' + ''|'' + ' end + 'isnull(rtrim(convert(varchar(100),s."' + @f + '")),'''')'
    end
    select @p = ''
    while 1 = 1
    begin
      select @p = min(POSITION) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG <> 'X' and INTTYPE = 'C' and POSITION > @p and FIELDNAME not like '.%'
      if @p is null break
      select @f = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and POSITION = @p
      select @d = @d + case when @d = '' then '' else ' or ' end + 's."' + @f + '" <> e."' + @f + '"'
      select @sql = 'select convert(varchar(290), ''#' + @t + '#'' + ' + @k + ' + ''#' + @f + '#S#'' + isnull(rtrim(s."' + @f + '"),'''')) k from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and s."' + @f + '" <> e."' + @f + '"'
       + ' union all select convert(varchar(290), ''#' + @t + '#'' + ' + @k + ' + ''#' + @f + '#E#'' + isnull(rtrim(e."' + @f + '"),'''')) k from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and s."' + @f + '" <> e."' + @f + '"'
      exec (@sql)
    end
    if @d = '' select @d = '1 = 0'
    select @sql = 'select ''#RESUMEN#' + @t + '#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock where s."' + @l + '" = ''S''))'
     + ' + ''#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock where s."' + @l + '" = ''S'' and not exists (select 1 from BAS.SAPSR3."' + @t + '" e noholdlock where e."' + @l + '" = ''E''' + @j + ')))'
     + ' + ''#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and (' + @d + ')))'
    exec (@sql)
  end
end
go
declare @t varchar(30), @l varchar(30), @p varchar(4), @f varchar(30), @j varchar(2000), @k varchar(2000), @d varchar(3000), @sql varchar(8000)
select @t = 'T011T', @j = '', @k = '', @d = '', @p = '', @l = null
if object_id('BAS.SAPSR3.T011T') is null
begin
  select '#T011T#NO_ES_TABLA_TRANSPARENTE'
end
else
begin
  select @l = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG = 'X' and DATATYPE = 'LANG'
  if @l is null select '#T011T#SIN_CAMPO_IDIOMA'
  else
  begin
    while 1 = 1
    begin
      select @p = min(POSITION) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG = 'X' and POSITION > @p and FIELDNAME not like '.%' and FIELDNAME <> @l
      if @p is null break
      select @f = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and POSITION = @p
      select @j = @j + ' and s."' + @f + '" = e."' + @f + '"'
      select @k = @k + case when @k = '' then '' else ' + ''|'' + ' end + 'isnull(rtrim(convert(varchar(100),s."' + @f + '")),'''')'
    end
    select @p = ''
    while 1 = 1
    begin
      select @p = min(POSITION) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG <> 'X' and INTTYPE = 'C' and POSITION > @p and FIELDNAME not like '.%'
      if @p is null break
      select @f = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and POSITION = @p
      select @d = @d + case when @d = '' then '' else ' or ' end + 's."' + @f + '" <> e."' + @f + '"'
      select @sql = 'select convert(varchar(290), ''#' + @t + '#'' + ' + @k + ' + ''#' + @f + '#S#'' + isnull(rtrim(s."' + @f + '"),'''')) k from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and s."' + @f + '" <> e."' + @f + '"'
       + ' union all select convert(varchar(290), ''#' + @t + '#'' + ' + @k + ' + ''#' + @f + '#E#'' + isnull(rtrim(e."' + @f + '"),'''')) k from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and s."' + @f + '" <> e."' + @f + '"'
      exec (@sql)
    end
    if @d = '' select @d = '1 = 0'
    select @sql = 'select ''#RESUMEN#' + @t + '#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock where s."' + @l + '" = ''S''))'
     + ' + ''#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock where s."' + @l + '" = ''S'' and not exists (select 1 from BAS.SAPSR3."' + @t + '" e noholdlock where e."' + @l + '" = ''E''' + @j + ')))'
     + ' + ''#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and (' + @d + ')))'
    exec (@sql)
  end
end
go
declare @t varchar(30), @l varchar(30), @p varchar(4), @f varchar(30), @j varchar(2000), @k varchar(2000), @d varchar(3000), @sql varchar(8000)
select @t = 'T014T', @j = '', @k = '', @d = '', @p = '', @l = null
if object_id('BAS.SAPSR3.T014T') is null
begin
  select '#T014T#NO_ES_TABLA_TRANSPARENTE'
end
else
begin
  select @l = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG = 'X' and DATATYPE = 'LANG'
  if @l is null select '#T014T#SIN_CAMPO_IDIOMA'
  else
  begin
    while 1 = 1
    begin
      select @p = min(POSITION) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG = 'X' and POSITION > @p and FIELDNAME not like '.%' and FIELDNAME <> @l
      if @p is null break
      select @f = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and POSITION = @p
      select @j = @j + ' and s."' + @f + '" = e."' + @f + '"'
      select @k = @k + case when @k = '' then '' else ' + ''|'' + ' end + 'isnull(rtrim(convert(varchar(100),s."' + @f + '")),'''')'
    end
    select @p = ''
    while 1 = 1
    begin
      select @p = min(POSITION) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG <> 'X' and INTTYPE = 'C' and POSITION > @p and FIELDNAME not like '.%'
      if @p is null break
      select @f = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and POSITION = @p
      select @d = @d + case when @d = '' then '' else ' or ' end + 's."' + @f + '" <> e."' + @f + '"'
      select @sql = 'select convert(varchar(290), ''#' + @t + '#'' + ' + @k + ' + ''#' + @f + '#S#'' + isnull(rtrim(s."' + @f + '"),'''')) k from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and s."' + @f + '" <> e."' + @f + '"'
       + ' union all select convert(varchar(290), ''#' + @t + '#'' + ' + @k + ' + ''#' + @f + '#E#'' + isnull(rtrim(e."' + @f + '"),'''')) k from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and s."' + @f + '" <> e."' + @f + '"'
      exec (@sql)
    end
    if @d = '' select @d = '1 = 0'
    select @sql = 'select ''#RESUMEN#' + @t + '#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock where s."' + @l + '" = ''S''))'
     + ' + ''#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock where s."' + @l + '" = ''S'' and not exists (select 1 from BAS.SAPSR3."' + @t + '" e noholdlock where e."' + @l + '" = ''E''' + @j + ')))'
     + ' + ''#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and (' + @d + ')))'
    exec (@sql)
  end
end
go
declare @t varchar(30), @l varchar(30), @p varchar(4), @f varchar(30), @j varchar(2000), @k varchar(2000), @d varchar(3000), @sql varchar(8000)
select @t = 'T015VT', @j = '', @k = '', @d = '', @p = '', @l = null
if object_id('BAS.SAPSR3.T015VT') is null
begin
  select '#T015VT#NO_ES_TABLA_TRANSPARENTE'
end
else
begin
  select @l = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG = 'X' and DATATYPE = 'LANG'
  if @l is null select '#T015VT#SIN_CAMPO_IDIOMA'
  else
  begin
    while 1 = 1
    begin
      select @p = min(POSITION) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG = 'X' and POSITION > @p and FIELDNAME not like '.%' and FIELDNAME <> @l
      if @p is null break
      select @f = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and POSITION = @p
      select @j = @j + ' and s."' + @f + '" = e."' + @f + '"'
      select @k = @k + case when @k = '' then '' else ' + ''|'' + ' end + 'isnull(rtrim(convert(varchar(100),s."' + @f + '")),'''')'
    end
    select @p = ''
    while 1 = 1
    begin
      select @p = min(POSITION) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG <> 'X' and INTTYPE = 'C' and POSITION > @p and FIELDNAME not like '.%'
      if @p is null break
      select @f = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and POSITION = @p
      select @d = @d + case when @d = '' then '' else ' or ' end + 's."' + @f + '" <> e."' + @f + '"'
      select @sql = 'select convert(varchar(290), ''#' + @t + '#'' + ' + @k + ' + ''#' + @f + '#S#'' + isnull(rtrim(s."' + @f + '"),'''')) k from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and s."' + @f + '" <> e."' + @f + '"'
       + ' union all select convert(varchar(290), ''#' + @t + '#'' + ' + @k + ' + ''#' + @f + '#E#'' + isnull(rtrim(e."' + @f + '"),'''')) k from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and s."' + @f + '" <> e."' + @f + '"'
      exec (@sql)
    end
    if @d = '' select @d = '1 = 0'
    select @sql = 'select ''#RESUMEN#' + @t + '#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock where s."' + @l + '" = ''S''))'
     + ' + ''#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock where s."' + @l + '" = ''S'' and not exists (select 1 from BAS.SAPSR3."' + @t + '" e noholdlock where e."' + @l + '" = ''E''' + @j + ')))'
     + ' + ''#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and (' + @d + ')))'
    exec (@sql)
  end
end
go
declare @t varchar(30), @l varchar(30), @p varchar(4), @f varchar(30), @j varchar(2000), @k varchar(2000), @d varchar(3000), @sql varchar(8000)
select @t = 'T015W1T', @j = '', @k = '', @d = '', @p = '', @l = null
if object_id('BAS.SAPSR3.T015W1T') is null
begin
  select '#T015W1T#NO_ES_TABLA_TRANSPARENTE'
end
else
begin
  select @l = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG = 'X' and DATATYPE = 'LANG'
  if @l is null select '#T015W1T#SIN_CAMPO_IDIOMA'
  else
  begin
    while 1 = 1
    begin
      select @p = min(POSITION) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG = 'X' and POSITION > @p and FIELDNAME not like '.%' and FIELDNAME <> @l
      if @p is null break
      select @f = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and POSITION = @p
      select @j = @j + ' and s."' + @f + '" = e."' + @f + '"'
      select @k = @k + case when @k = '' then '' else ' + ''|'' + ' end + 'isnull(rtrim(convert(varchar(100),s."' + @f + '")),'''')'
    end
    select @p = ''
    while 1 = 1
    begin
      select @p = min(POSITION) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG <> 'X' and INTTYPE = 'C' and POSITION > @p and FIELDNAME not like '.%'
      if @p is null break
      select @f = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and POSITION = @p
      select @d = @d + case when @d = '' then '' else ' or ' end + 's."' + @f + '" <> e."' + @f + '"'
      select @sql = 'select convert(varchar(290), ''#' + @t + '#'' + ' + @k + ' + ''#' + @f + '#S#'' + isnull(rtrim(s."' + @f + '"),'''')) k from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and s."' + @f + '" <> e."' + @f + '"'
       + ' union all select convert(varchar(290), ''#' + @t + '#'' + ' + @k + ' + ''#' + @f + '#E#'' + isnull(rtrim(e."' + @f + '"),'''')) k from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and s."' + @f + '" <> e."' + @f + '"'
      exec (@sql)
    end
    if @d = '' select @d = '1 = 0'
    select @sql = 'select ''#RESUMEN#' + @t + '#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock where s."' + @l + '" = ''S''))'
     + ' + ''#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock where s."' + @l + '" = ''S'' and not exists (select 1 from BAS.SAPSR3."' + @t + '" e noholdlock where e."' + @l + '" = ''E''' + @j + ')))'
     + ' + ''#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and (' + @d + ')))'
    exec (@sql)
  end
end
go
declare @t varchar(30), @l varchar(30), @p varchar(4), @f varchar(30), @j varchar(2000), @k varchar(2000), @d varchar(3000), @sql varchar(8000)
select @t = 'T015WT', @j = '', @k = '', @d = '', @p = '', @l = null
if object_id('BAS.SAPSR3.T015WT') is null
begin
  select '#T015WT#NO_ES_TABLA_TRANSPARENTE'
end
else
begin
  select @l = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG = 'X' and DATATYPE = 'LANG'
  if @l is null select '#T015WT#SIN_CAMPO_IDIOMA'
  else
  begin
    while 1 = 1
    begin
      select @p = min(POSITION) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG = 'X' and POSITION > @p and FIELDNAME not like '.%' and FIELDNAME <> @l
      if @p is null break
      select @f = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and POSITION = @p
      select @j = @j + ' and s."' + @f + '" = e."' + @f + '"'
      select @k = @k + case when @k = '' then '' else ' + ''|'' + ' end + 'isnull(rtrim(convert(varchar(100),s."' + @f + '")),'''')'
    end
    select @p = ''
    while 1 = 1
    begin
      select @p = min(POSITION) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG <> 'X' and INTTYPE = 'C' and POSITION > @p and FIELDNAME not like '.%'
      if @p is null break
      select @f = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and POSITION = @p
      select @d = @d + case when @d = '' then '' else ' or ' end + 's."' + @f + '" <> e."' + @f + '"'
      select @sql = 'select convert(varchar(290), ''#' + @t + '#'' + ' + @k + ' + ''#' + @f + '#S#'' + isnull(rtrim(s."' + @f + '"),'''')) k from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and s."' + @f + '" <> e."' + @f + '"'
       + ' union all select convert(varchar(290), ''#' + @t + '#'' + ' + @k + ' + ''#' + @f + '#E#'' + isnull(rtrim(e."' + @f + '"),'''')) k from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and s."' + @f + '" <> e."' + @f + '"'
      exec (@sql)
    end
    if @d = '' select @d = '1 = 0'
    select @sql = 'select ''#RESUMEN#' + @t + '#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock where s."' + @l + '" = ''S''))'
     + ' + ''#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock where s."' + @l + '" = ''S'' and not exists (select 1 from BAS.SAPSR3."' + @t + '" e noholdlock where e."' + @l + '" = ''E''' + @j + ')))'
     + ' + ''#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and (' + @d + ')))'
    exec (@sql)
  end
end
go
declare @t varchar(30), @l varchar(30), @p varchar(4), @f varchar(30), @j varchar(2000), @k varchar(2000), @d varchar(3000), @sql varchar(8000)
select @t = 'T015XT', @j = '', @k = '', @d = '', @p = '', @l = null
if object_id('BAS.SAPSR3.T015XT') is null
begin
  select '#T015XT#NO_ES_TABLA_TRANSPARENTE'
end
else
begin
  select @l = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG = 'X' and DATATYPE = 'LANG'
  if @l is null select '#T015XT#SIN_CAMPO_IDIOMA'
  else
  begin
    while 1 = 1
    begin
      select @p = min(POSITION) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG = 'X' and POSITION > @p and FIELDNAME not like '.%' and FIELDNAME <> @l
      if @p is null break
      select @f = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and POSITION = @p
      select @j = @j + ' and s."' + @f + '" = e."' + @f + '"'
      select @k = @k + case when @k = '' then '' else ' + ''|'' + ' end + 'isnull(rtrim(convert(varchar(100),s."' + @f + '")),'''')'
    end
    select @p = ''
    while 1 = 1
    begin
      select @p = min(POSITION) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG <> 'X' and INTTYPE = 'C' and POSITION > @p and FIELDNAME not like '.%'
      if @p is null break
      select @f = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and POSITION = @p
      select @d = @d + case when @d = '' then '' else ' or ' end + 's."' + @f + '" <> e."' + @f + '"'
      select @sql = 'select convert(varchar(290), ''#' + @t + '#'' + ' + @k + ' + ''#' + @f + '#S#'' + isnull(rtrim(s."' + @f + '"),'''')) k from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and s."' + @f + '" <> e."' + @f + '"'
       + ' union all select convert(varchar(290), ''#' + @t + '#'' + ' + @k + ' + ''#' + @f + '#E#'' + isnull(rtrim(e."' + @f + '"),'''')) k from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and s."' + @f + '" <> e."' + @f + '"'
      exec (@sql)
    end
    if @d = '' select @d = '1 = 0'
    select @sql = 'select ''#RESUMEN#' + @t + '#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock where s."' + @l + '" = ''S''))'
     + ' + ''#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock where s."' + @l + '" = ''S'' and not exists (select 1 from BAS.SAPSR3."' + @t + '" e noholdlock where e."' + @l + '" = ''E''' + @j + ')))'
     + ' + ''#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and (' + @d + ')))'
    exec (@sql)
  end
end
go
declare @t varchar(30), @l varchar(30), @p varchar(4), @f varchar(30), @j varchar(2000), @k varchar(2000), @d varchar(3000), @sql varchar(8000)
select @t = 'T021STDT', @j = '', @k = '', @d = '', @p = '', @l = null
if object_id('BAS.SAPSR3.T021STDT') is null
begin
  select '#T021STDT#NO_ES_TABLA_TRANSPARENTE'
end
else
begin
  select @l = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG = 'X' and DATATYPE = 'LANG'
  if @l is null select '#T021STDT#SIN_CAMPO_IDIOMA'
  else
  begin
    while 1 = 1
    begin
      select @p = min(POSITION) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG = 'X' and POSITION > @p and FIELDNAME not like '.%' and FIELDNAME <> @l
      if @p is null break
      select @f = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and POSITION = @p
      select @j = @j + ' and s."' + @f + '" = e."' + @f + '"'
      select @k = @k + case when @k = '' then '' else ' + ''|'' + ' end + 'isnull(rtrim(convert(varchar(100),s."' + @f + '")),'''')'
    end
    select @p = ''
    while 1 = 1
    begin
      select @p = min(POSITION) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG <> 'X' and INTTYPE = 'C' and POSITION > @p and FIELDNAME not like '.%'
      if @p is null break
      select @f = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and POSITION = @p
      select @d = @d + case when @d = '' then '' else ' or ' end + 's."' + @f + '" <> e."' + @f + '"'
      select @sql = 'select convert(varchar(290), ''#' + @t + '#'' + ' + @k + ' + ''#' + @f + '#S#'' + isnull(rtrim(s."' + @f + '"),'''')) k from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and s."' + @f + '" <> e."' + @f + '"'
       + ' union all select convert(varchar(290), ''#' + @t + '#'' + ' + @k + ' + ''#' + @f + '#E#'' + isnull(rtrim(e."' + @f + '"),'''')) k from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and s."' + @f + '" <> e."' + @f + '"'
      exec (@sql)
    end
    if @d = '' select @d = '1 = 0'
    select @sql = 'select ''#RESUMEN#' + @t + '#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock where s."' + @l + '" = ''S''))'
     + ' + ''#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock where s."' + @l + '" = ''S'' and not exists (select 1 from BAS.SAPSR3."' + @t + '" e noholdlock where e."' + @l + '" = ''E''' + @j + ')))'
     + ' + ''#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and (' + @d + ')))'
    exec (@sql)
  end
end
go
declare @t varchar(30), @l varchar(30), @p varchar(4), @f varchar(30), @j varchar(2000), @k varchar(2000), @d varchar(3000), @sql varchar(8000)
select @t = 'T022T', @j = '', @k = '', @d = '', @p = '', @l = null
if object_id('BAS.SAPSR3.T022T') is null
begin
  select '#T022T#NO_ES_TABLA_TRANSPARENTE'
end
else
begin
  select @l = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG = 'X' and DATATYPE = 'LANG'
  if @l is null select '#T022T#SIN_CAMPO_IDIOMA'
  else
  begin
    while 1 = 1
    begin
      select @p = min(POSITION) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG = 'X' and POSITION > @p and FIELDNAME not like '.%' and FIELDNAME <> @l
      if @p is null break
      select @f = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and POSITION = @p
      select @j = @j + ' and s."' + @f + '" = e."' + @f + '"'
      select @k = @k + case when @k = '' then '' else ' + ''|'' + ' end + 'isnull(rtrim(convert(varchar(100),s."' + @f + '")),'''')'
    end
    select @p = ''
    while 1 = 1
    begin
      select @p = min(POSITION) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG <> 'X' and INTTYPE = 'C' and POSITION > @p and FIELDNAME not like '.%'
      if @p is null break
      select @f = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and POSITION = @p
      select @d = @d + case when @d = '' then '' else ' or ' end + 's."' + @f + '" <> e."' + @f + '"'
      select @sql = 'select convert(varchar(290), ''#' + @t + '#'' + ' + @k + ' + ''#' + @f + '#S#'' + isnull(rtrim(s."' + @f + '"),'''')) k from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and s."' + @f + '" <> e."' + @f + '"'
       + ' union all select convert(varchar(290), ''#' + @t + '#'' + ' + @k + ' + ''#' + @f + '#E#'' + isnull(rtrim(e."' + @f + '"),'''')) k from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and s."' + @f + '" <> e."' + @f + '"'
      exec (@sql)
    end
    if @d = '' select @d = '1 = 0'
    select @sql = 'select ''#RESUMEN#' + @t + '#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock where s."' + @l + '" = ''S''))'
     + ' + ''#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock where s."' + @l + '" = ''S'' and not exists (select 1 from BAS.SAPSR3."' + @t + '" e noholdlock where e."' + @l + '" = ''E''' + @j + ')))'
     + ' + ''#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and (' + @d + ')))'
    exec (@sql)
  end
end
go
declare @t varchar(30), @l varchar(30), @p varchar(4), @f varchar(30), @j varchar(2000), @k varchar(2000), @d varchar(3000), @sql varchar(8000)
select @t = 'T023T', @j = '', @k = '', @d = '', @p = '', @l = null
if object_id('BAS.SAPSR3.T023T') is null
begin
  select '#T023T#NO_ES_TABLA_TRANSPARENTE'
end
else
begin
  select @l = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG = 'X' and DATATYPE = 'LANG'
  if @l is null select '#T023T#SIN_CAMPO_IDIOMA'
  else
  begin
    while 1 = 1
    begin
      select @p = min(POSITION) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG = 'X' and POSITION > @p and FIELDNAME not like '.%' and FIELDNAME <> @l
      if @p is null break
      select @f = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and POSITION = @p
      select @j = @j + ' and s."' + @f + '" = e."' + @f + '"'
      select @k = @k + case when @k = '' then '' else ' + ''|'' + ' end + 'isnull(rtrim(convert(varchar(100),s."' + @f + '")),'''')'
    end
    select @p = ''
    while 1 = 1
    begin
      select @p = min(POSITION) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG <> 'X' and INTTYPE = 'C' and POSITION > @p and FIELDNAME not like '.%'
      if @p is null break
      select @f = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and POSITION = @p
      select @d = @d + case when @d = '' then '' else ' or ' end + 's."' + @f + '" <> e."' + @f + '"'
      select @sql = 'select convert(varchar(290), ''#' + @t + '#'' + ' + @k + ' + ''#' + @f + '#S#'' + isnull(rtrim(s."' + @f + '"),'''')) k from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and s."' + @f + '" <> e."' + @f + '"'
       + ' union all select convert(varchar(290), ''#' + @t + '#'' + ' + @k + ' + ''#' + @f + '#E#'' + isnull(rtrim(e."' + @f + '"),'''')) k from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and s."' + @f + '" <> e."' + @f + '"'
      exec (@sql)
    end
    if @d = '' select @d = '1 = 0'
    select @sql = 'select ''#RESUMEN#' + @t + '#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock where s."' + @l + '" = ''S''))'
     + ' + ''#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock where s."' + @l + '" = ''S'' and not exists (select 1 from BAS.SAPSR3."' + @t + '" e noholdlock where e."' + @l + '" = ''E''' + @j + ')))'
     + ' + ''#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and (' + @d + ')))'
    exec (@sql)
  end
end
go
declare @t varchar(30), @l varchar(30), @p varchar(4), @f varchar(30), @j varchar(2000), @k varchar(2000), @d varchar(3000), @sql varchar(8000)
select @t = 'T025T', @j = '', @k = '', @d = '', @p = '', @l = null
if object_id('BAS.SAPSR3.T025T') is null
begin
  select '#T025T#NO_ES_TABLA_TRANSPARENTE'
end
else
begin
  select @l = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG = 'X' and DATATYPE = 'LANG'
  if @l is null select '#T025T#SIN_CAMPO_IDIOMA'
  else
  begin
    while 1 = 1
    begin
      select @p = min(POSITION) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG = 'X' and POSITION > @p and FIELDNAME not like '.%' and FIELDNAME <> @l
      if @p is null break
      select @f = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and POSITION = @p
      select @j = @j + ' and s."' + @f + '" = e."' + @f + '"'
      select @k = @k + case when @k = '' then '' else ' + ''|'' + ' end + 'isnull(rtrim(convert(varchar(100),s."' + @f + '")),'''')'
    end
    select @p = ''
    while 1 = 1
    begin
      select @p = min(POSITION) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG <> 'X' and INTTYPE = 'C' and POSITION > @p and FIELDNAME not like '.%'
      if @p is null break
      select @f = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and POSITION = @p
      select @d = @d + case when @d = '' then '' else ' or ' end + 's."' + @f + '" <> e."' + @f + '"'
      select @sql = 'select convert(varchar(290), ''#' + @t + '#'' + ' + @k + ' + ''#' + @f + '#S#'' + isnull(rtrim(s."' + @f + '"),'''')) k from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and s."' + @f + '" <> e."' + @f + '"'
       + ' union all select convert(varchar(290), ''#' + @t + '#'' + ' + @k + ' + ''#' + @f + '#E#'' + isnull(rtrim(e."' + @f + '"),'''')) k from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and s."' + @f + '" <> e."' + @f + '"'
      exec (@sql)
    end
    if @d = '' select @d = '1 = 0'
    select @sql = 'select ''#RESUMEN#' + @t + '#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock where s."' + @l + '" = ''S''))'
     + ' + ''#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock where s."' + @l + '" = ''S'' and not exists (select 1 from BAS.SAPSR3."' + @t + '" e noholdlock where e."' + @l + '" = ''E''' + @j + ')))'
     + ' + ''#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and (' + @d + ')))'
    exec (@sql)
  end
end
go
declare @t varchar(30), @l varchar(30), @p varchar(4), @f varchar(30), @j varchar(2000), @k varchar(2000), @d varchar(3000), @sql varchar(8000)
select @t = 'T026T', @j = '', @k = '', @d = '', @p = '', @l = null
if object_id('BAS.SAPSR3.T026T') is null
begin
  select '#T026T#NO_ES_TABLA_TRANSPARENTE'
end
else
begin
  select @l = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG = 'X' and DATATYPE = 'LANG'
  if @l is null select '#T026T#SIN_CAMPO_IDIOMA'
  else
  begin
    while 1 = 1
    begin
      select @p = min(POSITION) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG = 'X' and POSITION > @p and FIELDNAME not like '.%' and FIELDNAME <> @l
      if @p is null break
      select @f = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and POSITION = @p
      select @j = @j + ' and s."' + @f + '" = e."' + @f + '"'
      select @k = @k + case when @k = '' then '' else ' + ''|'' + ' end + 'isnull(rtrim(convert(varchar(100),s."' + @f + '")),'''')'
    end
    select @p = ''
    while 1 = 1
    begin
      select @p = min(POSITION) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG <> 'X' and INTTYPE = 'C' and POSITION > @p and FIELDNAME not like '.%'
      if @p is null break
      select @f = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and POSITION = @p
      select @d = @d + case when @d = '' then '' else ' or ' end + 's."' + @f + '" <> e."' + @f + '"'
      select @sql = 'select convert(varchar(290), ''#' + @t + '#'' + ' + @k + ' + ''#' + @f + '#S#'' + isnull(rtrim(s."' + @f + '"),'''')) k from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and s."' + @f + '" <> e."' + @f + '"'
       + ' union all select convert(varchar(290), ''#' + @t + '#'' + ' + @k + ' + ''#' + @f + '#E#'' + isnull(rtrim(e."' + @f + '"),'''')) k from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and s."' + @f + '" <> e."' + @f + '"'
      exec (@sql)
    end
    if @d = '' select @d = '1 = 0'
    select @sql = 'select ''#RESUMEN#' + @t + '#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock where s."' + @l + '" = ''S''))'
     + ' + ''#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock where s."' + @l + '" = ''S'' and not exists (select 1 from BAS.SAPSR3."' + @t + '" e noholdlock where e."' + @l + '" = ''E''' + @j + ')))'
     + ' + ''#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and (' + @d + ')))'
    exec (@sql)
  end
end
go
declare @t varchar(30), @l varchar(30), @p varchar(4), @f varchar(30), @j varchar(2000), @k varchar(2000), @d varchar(3000), @sql varchar(8000)
select @t = 'T035T', @j = '', @k = '', @d = '', @p = '', @l = null
if object_id('BAS.SAPSR3.T035T') is null
begin
  select '#T035T#NO_ES_TABLA_TRANSPARENTE'
end
else
begin
  select @l = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG = 'X' and DATATYPE = 'LANG'
  if @l is null select '#T035T#SIN_CAMPO_IDIOMA'
  else
  begin
    while 1 = 1
    begin
      select @p = min(POSITION) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG = 'X' and POSITION > @p and FIELDNAME not like '.%' and FIELDNAME <> @l
      if @p is null break
      select @f = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and POSITION = @p
      select @j = @j + ' and s."' + @f + '" = e."' + @f + '"'
      select @k = @k + case when @k = '' then '' else ' + ''|'' + ' end + 'isnull(rtrim(convert(varchar(100),s."' + @f + '")),'''')'
    end
    select @p = ''
    while 1 = 1
    begin
      select @p = min(POSITION) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG <> 'X' and INTTYPE = 'C' and POSITION > @p and FIELDNAME not like '.%'
      if @p is null break
      select @f = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and POSITION = @p
      select @d = @d + case when @d = '' then '' else ' or ' end + 's."' + @f + '" <> e."' + @f + '"'
      select @sql = 'select convert(varchar(290), ''#' + @t + '#'' + ' + @k + ' + ''#' + @f + '#S#'' + isnull(rtrim(s."' + @f + '"),'''')) k from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and s."' + @f + '" <> e."' + @f + '"'
       + ' union all select convert(varchar(290), ''#' + @t + '#'' + ' + @k + ' + ''#' + @f + '#E#'' + isnull(rtrim(e."' + @f + '"),'''')) k from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and s."' + @f + '" <> e."' + @f + '"'
      exec (@sql)
    end
    if @d = '' select @d = '1 = 0'
    select @sql = 'select ''#RESUMEN#' + @t + '#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock where s."' + @l + '" = ''S''))'
     + ' + ''#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock where s."' + @l + '" = ''S'' and not exists (select 1 from BAS.SAPSR3."' + @t + '" e noholdlock where e."' + @l + '" = ''E''' + @j + ')))'
     + ' + ''#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and (' + @d + ')))'
    exec (@sql)
  end
end
go
declare @t varchar(30), @l varchar(30), @p varchar(4), @f varchar(30), @j varchar(2000), @k varchar(2000), @d varchar(3000), @sql varchar(8000)
select @t = 'T036T', @j = '', @k = '', @d = '', @p = '', @l = null
if object_id('BAS.SAPSR3.T036T') is null
begin
  select '#T036T#NO_ES_TABLA_TRANSPARENTE'
end
else
begin
  select @l = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG = 'X' and DATATYPE = 'LANG'
  if @l is null select '#T036T#SIN_CAMPO_IDIOMA'
  else
  begin
    while 1 = 1
    begin
      select @p = min(POSITION) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG = 'X' and POSITION > @p and FIELDNAME not like '.%' and FIELDNAME <> @l
      if @p is null break
      select @f = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and POSITION = @p
      select @j = @j + ' and s."' + @f + '" = e."' + @f + '"'
      select @k = @k + case when @k = '' then '' else ' + ''|'' + ' end + 'isnull(rtrim(convert(varchar(100),s."' + @f + '")),'''')'
    end
    select @p = ''
    while 1 = 1
    begin
      select @p = min(POSITION) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG <> 'X' and INTTYPE = 'C' and POSITION > @p and FIELDNAME not like '.%'
      if @p is null break
      select @f = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and POSITION = @p
      select @d = @d + case when @d = '' then '' else ' or ' end + 's."' + @f + '" <> e."' + @f + '"'
      select @sql = 'select convert(varchar(290), ''#' + @t + '#'' + ' + @k + ' + ''#' + @f + '#S#'' + isnull(rtrim(s."' + @f + '"),'''')) k from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and s."' + @f + '" <> e."' + @f + '"'
       + ' union all select convert(varchar(290), ''#' + @t + '#'' + ' + @k + ' + ''#' + @f + '#E#'' + isnull(rtrim(e."' + @f + '"),'''')) k from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and s."' + @f + '" <> e."' + @f + '"'
      exec (@sql)
    end
    if @d = '' select @d = '1 = 0'
    select @sql = 'select ''#RESUMEN#' + @t + '#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock where s."' + @l + '" = ''S''))'
     + ' + ''#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock where s."' + @l + '" = ''S'' and not exists (select 1 from BAS.SAPSR3."' + @t + '" e noholdlock where e."' + @l + '" = ''E''' + @j + ')))'
     + ' + ''#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and (' + @d + ')))'
    exec (@sql)
  end
end
go
declare @t varchar(30), @l varchar(30), @p varchar(4), @f varchar(30), @j varchar(2000), @k varchar(2000), @d varchar(3000), @sql varchar(8000)
select @t = 'T039T', @j = '', @k = '', @d = '', @p = '', @l = null
if object_id('BAS.SAPSR3.T039T') is null
begin
  select '#T039T#NO_ES_TABLA_TRANSPARENTE'
end
else
begin
  select @l = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG = 'X' and DATATYPE = 'LANG'
  if @l is null select '#T039T#SIN_CAMPO_IDIOMA'
  else
  begin
    while 1 = 1
    begin
      select @p = min(POSITION) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG = 'X' and POSITION > @p and FIELDNAME not like '.%' and FIELDNAME <> @l
      if @p is null break
      select @f = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and POSITION = @p
      select @j = @j + ' and s."' + @f + '" = e."' + @f + '"'
      select @k = @k + case when @k = '' then '' else ' + ''|'' + ' end + 'isnull(rtrim(convert(varchar(100),s."' + @f + '")),'''')'
    end
    select @p = ''
    while 1 = 1
    begin
      select @p = min(POSITION) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG <> 'X' and INTTYPE = 'C' and POSITION > @p and FIELDNAME not like '.%'
      if @p is null break
      select @f = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and POSITION = @p
      select @d = @d + case when @d = '' then '' else ' or ' end + 's."' + @f + '" <> e."' + @f + '"'
      select @sql = 'select convert(varchar(290), ''#' + @t + '#'' + ' + @k + ' + ''#' + @f + '#S#'' + isnull(rtrim(s."' + @f + '"),'''')) k from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and s."' + @f + '" <> e."' + @f + '"'
       + ' union all select convert(varchar(290), ''#' + @t + '#'' + ' + @k + ' + ''#' + @f + '#E#'' + isnull(rtrim(e."' + @f + '"),'''')) k from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and s."' + @f + '" <> e."' + @f + '"'
      exec (@sql)
    end
    if @d = '' select @d = '1 = 0'
    select @sql = 'select ''#RESUMEN#' + @t + '#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock where s."' + @l + '" = ''S''))'
     + ' + ''#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock where s."' + @l + '" = ''S'' and not exists (select 1 from BAS.SAPSR3."' + @t + '" e noholdlock where e."' + @l + '" = ''E''' + @j + ')))'
     + ' + ''#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and (' + @d + ')))'
    exec (@sql)
  end
end
go
declare @t varchar(30), @l varchar(30), @p varchar(4), @f varchar(30), @j varchar(2000), @k varchar(2000), @d varchar(3000), @sql varchar(8000)
select @t = 'T041CT', @j = '', @k = '', @d = '', @p = '', @l = null
if object_id('BAS.SAPSR3.T041CT') is null
begin
  select '#T041CT#NO_ES_TABLA_TRANSPARENTE'
end
else
begin
  select @l = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG = 'X' and DATATYPE = 'LANG'
  if @l is null select '#T041CT#SIN_CAMPO_IDIOMA'
  else
  begin
    while 1 = 1
    begin
      select @p = min(POSITION) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG = 'X' and POSITION > @p and FIELDNAME not like '.%' and FIELDNAME <> @l
      if @p is null break
      select @f = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and POSITION = @p
      select @j = @j + ' and s."' + @f + '" = e."' + @f + '"'
      select @k = @k + case when @k = '' then '' else ' + ''|'' + ' end + 'isnull(rtrim(convert(varchar(100),s."' + @f + '")),'''')'
    end
    select @p = ''
    while 1 = 1
    begin
      select @p = min(POSITION) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG <> 'X' and INTTYPE = 'C' and POSITION > @p and FIELDNAME not like '.%'
      if @p is null break
      select @f = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and POSITION = @p
      select @d = @d + case when @d = '' then '' else ' or ' end + 's."' + @f + '" <> e."' + @f + '"'
      select @sql = 'select convert(varchar(290), ''#' + @t + '#'' + ' + @k + ' + ''#' + @f + '#S#'' + isnull(rtrim(s."' + @f + '"),'''')) k from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and s."' + @f + '" <> e."' + @f + '"'
       + ' union all select convert(varchar(290), ''#' + @t + '#'' + ' + @k + ' + ''#' + @f + '#E#'' + isnull(rtrim(e."' + @f + '"),'''')) k from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and s."' + @f + '" <> e."' + @f + '"'
      exec (@sql)
    end
    if @d = '' select @d = '1 = 0'
    select @sql = 'select ''#RESUMEN#' + @t + '#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock where s."' + @l + '" = ''S''))'
     + ' + ''#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock where s."' + @l + '" = ''S'' and not exists (select 1 from BAS.SAPSR3."' + @t + '" e noholdlock where e."' + @l + '" = ''E''' + @j + ')))'
     + ' + ''#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and (' + @d + ')))'
    exec (@sql)
  end
end
go
declare @t varchar(30), @l varchar(30), @p varchar(4), @f varchar(30), @j varchar(2000), @k varchar(2000), @d varchar(3000), @sql varchar(8000)
select @t = 'T042ZDT', @j = '', @k = '', @d = '', @p = '', @l = null
if object_id('BAS.SAPSR3.T042ZDT') is null
begin
  select '#T042ZDT#NO_ES_TABLA_TRANSPARENTE'
end
else
begin
  select @l = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG = 'X' and DATATYPE = 'LANG'
  if @l is null select '#T042ZDT#SIN_CAMPO_IDIOMA'
  else
  begin
    while 1 = 1
    begin
      select @p = min(POSITION) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG = 'X' and POSITION > @p and FIELDNAME not like '.%' and FIELDNAME <> @l
      if @p is null break
      select @f = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and POSITION = @p
      select @j = @j + ' and s."' + @f + '" = e."' + @f + '"'
      select @k = @k + case when @k = '' then '' else ' + ''|'' + ' end + 'isnull(rtrim(convert(varchar(100),s."' + @f + '")),'''')'
    end
    select @p = ''
    while 1 = 1
    begin
      select @p = min(POSITION) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG <> 'X' and INTTYPE = 'C' and POSITION > @p and FIELDNAME not like '.%'
      if @p is null break
      select @f = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and POSITION = @p
      select @d = @d + case when @d = '' then '' else ' or ' end + 's."' + @f + '" <> e."' + @f + '"'
      select @sql = 'select convert(varchar(290), ''#' + @t + '#'' + ' + @k + ' + ''#' + @f + '#S#'' + isnull(rtrim(s."' + @f + '"),'''')) k from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and s."' + @f + '" <> e."' + @f + '"'
       + ' union all select convert(varchar(290), ''#' + @t + '#'' + ' + @k + ' + ''#' + @f + '#E#'' + isnull(rtrim(e."' + @f + '"),'''')) k from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and s."' + @f + '" <> e."' + @f + '"'
      exec (@sql)
    end
    if @d = '' select @d = '1 = 0'
    select @sql = 'select ''#RESUMEN#' + @t + '#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock where s."' + @l + '" = ''S''))'
     + ' + ''#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock where s."' + @l + '" = ''S'' and not exists (select 1 from BAS.SAPSR3."' + @t + '" e noholdlock where e."' + @l + '" = ''E''' + @j + ')))'
     + ' + ''#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and (' + @d + ')))'
    exec (@sql)
  end
end
go
declare @t varchar(30), @l varchar(30), @p varchar(4), @f varchar(30), @j varchar(2000), @k varchar(2000), @d varchar(3000), @sql varchar(8000)
select @t = 'T043ST', @j = '', @k = '', @d = '', @p = '', @l = null
if object_id('BAS.SAPSR3.T043ST') is null
begin
  select '#T043ST#NO_ES_TABLA_TRANSPARENTE'
end
else
begin
  select @l = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG = 'X' and DATATYPE = 'LANG'
  if @l is null select '#T043ST#SIN_CAMPO_IDIOMA'
  else
  begin
    while 1 = 1
    begin
      select @p = min(POSITION) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG = 'X' and POSITION > @p and FIELDNAME not like '.%' and FIELDNAME <> @l
      if @p is null break
      select @f = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and POSITION = @p
      select @j = @j + ' and s."' + @f + '" = e."' + @f + '"'
      select @k = @k + case when @k = '' then '' else ' + ''|'' + ' end + 'isnull(rtrim(convert(varchar(100),s."' + @f + '")),'''')'
    end
    select @p = ''
    while 1 = 1
    begin
      select @p = min(POSITION) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG <> 'X' and INTTYPE = 'C' and POSITION > @p and FIELDNAME not like '.%'
      if @p is null break
      select @f = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and POSITION = @p
      select @d = @d + case when @d = '' then '' else ' or ' end + 's."' + @f + '" <> e."' + @f + '"'
      select @sql = 'select convert(varchar(290), ''#' + @t + '#'' + ' + @k + ' + ''#' + @f + '#S#'' + isnull(rtrim(s."' + @f + '"),'''')) k from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and s."' + @f + '" <> e."' + @f + '"'
       + ' union all select convert(varchar(290), ''#' + @t + '#'' + ' + @k + ' + ''#' + @f + '#E#'' + isnull(rtrim(e."' + @f + '"),'''')) k from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and s."' + @f + '" <> e."' + @f + '"'
      exec (@sql)
    end
    if @d = '' select @d = '1 = 0'
    select @sql = 'select ''#RESUMEN#' + @t + '#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock where s."' + @l + '" = ''S''))'
     + ' + ''#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock where s."' + @l + '" = ''S'' and not exists (select 1 from BAS.SAPSR3."' + @t + '" e noholdlock where e."' + @l + '" = ''E''' + @j + ')))'
     + ' + ''#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and (' + @d + ')))'
    exec (@sql)
  end
end
go
declare @t varchar(30), @l varchar(30), @p varchar(4), @f varchar(30), @j varchar(2000), @k varchar(2000), @d varchar(3000), @sql varchar(8000)
select @t = 'T053S', @j = '', @k = '', @d = '', @p = '', @l = null
if object_id('BAS.SAPSR3.T053S') is null
begin
  select '#T053S#NO_ES_TABLA_TRANSPARENTE'
end
else
begin
  select @l = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG = 'X' and DATATYPE = 'LANG'
  if @l is null select '#T053S#SIN_CAMPO_IDIOMA'
  else
  begin
    while 1 = 1
    begin
      select @p = min(POSITION) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG = 'X' and POSITION > @p and FIELDNAME not like '.%' and FIELDNAME <> @l
      if @p is null break
      select @f = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and POSITION = @p
      select @j = @j + ' and s."' + @f + '" = e."' + @f + '"'
      select @k = @k + case when @k = '' then '' else ' + ''|'' + ' end + 'isnull(rtrim(convert(varchar(100),s."' + @f + '")),'''')'
    end
    select @p = ''
    while 1 = 1
    begin
      select @p = min(POSITION) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG <> 'X' and INTTYPE = 'C' and POSITION > @p and FIELDNAME not like '.%'
      if @p is null break
      select @f = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and POSITION = @p
      select @d = @d + case when @d = '' then '' else ' or ' end + 's."' + @f + '" <> e."' + @f + '"'
      select @sql = 'select convert(varchar(290), ''#' + @t + '#'' + ' + @k + ' + ''#' + @f + '#S#'' + isnull(rtrim(s."' + @f + '"),'''')) k from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and s."' + @f + '" <> e."' + @f + '"'
       + ' union all select convert(varchar(290), ''#' + @t + '#'' + ' + @k + ' + ''#' + @f + '#E#'' + isnull(rtrim(e."' + @f + '"),'''')) k from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and s."' + @f + '" <> e."' + @f + '"'
      exec (@sql)
    end
    if @d = '' select @d = '1 = 0'
    select @sql = 'select ''#RESUMEN#' + @t + '#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock where s."' + @l + '" = ''S''))'
     + ' + ''#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock where s."' + @l + '" = ''S'' and not exists (select 1 from BAS.SAPSR3."' + @t + '" e noholdlock where e."' + @l + '" = ''E''' + @j + ')))'
     + ' + ''#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and (' + @d + ')))'
    exec (@sql)
  end
end
go
declare @t varchar(30), @l varchar(30), @p varchar(4), @f varchar(30), @j varchar(2000), @k varchar(2000), @d varchar(3000), @sql varchar(8000)
select @t = 'T058T', @j = '', @k = '', @d = '', @p = '', @l = null
if object_id('BAS.SAPSR3.T058T') is null
begin
  select '#T058T#NO_ES_TABLA_TRANSPARENTE'
end
else
begin
  select @l = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG = 'X' and DATATYPE = 'LANG'
  if @l is null select '#T058T#SIN_CAMPO_IDIOMA'
  else
  begin
    while 1 = 1
    begin
      select @p = min(POSITION) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG = 'X' and POSITION > @p and FIELDNAME not like '.%' and FIELDNAME <> @l
      if @p is null break
      select @f = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and POSITION = @p
      select @j = @j + ' and s."' + @f + '" = e."' + @f + '"'
      select @k = @k + case when @k = '' then '' else ' + ''|'' + ' end + 'isnull(rtrim(convert(varchar(100),s."' + @f + '")),'''')'
    end
    select @p = ''
    while 1 = 1
    begin
      select @p = min(POSITION) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG <> 'X' and INTTYPE = 'C' and POSITION > @p and FIELDNAME not like '.%'
      if @p is null break
      select @f = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and POSITION = @p
      select @d = @d + case when @d = '' then '' else ' or ' end + 's."' + @f + '" <> e."' + @f + '"'
      select @sql = 'select convert(varchar(290), ''#' + @t + '#'' + ' + @k + ' + ''#' + @f + '#S#'' + isnull(rtrim(s."' + @f + '"),'''')) k from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and s."' + @f + '" <> e."' + @f + '"'
       + ' union all select convert(varchar(290), ''#' + @t + '#'' + ' + @k + ' + ''#' + @f + '#E#'' + isnull(rtrim(e."' + @f + '"),'''')) k from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and s."' + @f + '" <> e."' + @f + '"'
      exec (@sql)
    end
    if @d = '' select @d = '1 = 0'
    select @sql = 'select ''#RESUMEN#' + @t + '#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock where s."' + @l + '" = ''S''))'
     + ' + ''#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock where s."' + @l + '" = ''S'' and not exists (select 1 from BAS.SAPSR3."' + @t + '" e noholdlock where e."' + @l + '" = ''E''' + @j + ')))'
     + ' + ''#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and (' + @d + ')))'
    exec (@sql)
  end
end
go
declare @t varchar(30), @l varchar(30), @p varchar(4), @f varchar(30), @j varchar(2000), @k varchar(2000), @d varchar(3000), @sql varchar(8000)
select @t = 'T059U', @j = '', @k = '', @d = '', @p = '', @l = null
if object_id('BAS.SAPSR3.T059U') is null
begin
  select '#T059U#NO_ES_TABLA_TRANSPARENTE'
end
else
begin
  select @l = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG = 'X' and DATATYPE = 'LANG'
  if @l is null select '#T059U#SIN_CAMPO_IDIOMA'
  else
  begin
    while 1 = 1
    begin
      select @p = min(POSITION) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG = 'X' and POSITION > @p and FIELDNAME not like '.%' and FIELDNAME <> @l
      if @p is null break
      select @f = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and POSITION = @p
      select @j = @j + ' and s."' + @f + '" = e."' + @f + '"'
      select @k = @k + case when @k = '' then '' else ' + ''|'' + ' end + 'isnull(rtrim(convert(varchar(100),s."' + @f + '")),'''')'
    end
    select @p = ''
    while 1 = 1
    begin
      select @p = min(POSITION) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG <> 'X' and INTTYPE = 'C' and POSITION > @p and FIELDNAME not like '.%'
      if @p is null break
      select @f = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and POSITION = @p
      select @d = @d + case when @d = '' then '' else ' or ' end + 's."' + @f + '" <> e."' + @f + '"'
      select @sql = 'select convert(varchar(290), ''#' + @t + '#'' + ' + @k + ' + ''#' + @f + '#S#'' + isnull(rtrim(s."' + @f + '"),'''')) k from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and s."' + @f + '" <> e."' + @f + '"'
       + ' union all select convert(varchar(290), ''#' + @t + '#'' + ' + @k + ' + ''#' + @f + '#E#'' + isnull(rtrim(e."' + @f + '"),'''')) k from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and s."' + @f + '" <> e."' + @f + '"'
      exec (@sql)
    end
    if @d = '' select @d = '1 = 0'
    select @sql = 'select ''#RESUMEN#' + @t + '#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock where s."' + @l + '" = ''S''))'
     + ' + ''#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock where s."' + @l + '" = ''S'' and not exists (select 1 from BAS.SAPSR3."' + @t + '" e noholdlock where e."' + @l + '" = ''E''' + @j + ')))'
     + ' + ''#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and (' + @d + ')))'
    exec (@sql)
  end
end
go
declare @t varchar(30), @l varchar(30), @p varchar(4), @f varchar(30), @j varchar(2000), @k varchar(2000), @d varchar(3000), @sql varchar(8000)
select @t = 'T059ZT', @j = '', @k = '', @d = '', @p = '', @l = null
if object_id('BAS.SAPSR3.T059ZT') is null
begin
  select '#T059ZT#NO_ES_TABLA_TRANSPARENTE'
end
else
begin
  select @l = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG = 'X' and DATATYPE = 'LANG'
  if @l is null select '#T059ZT#SIN_CAMPO_IDIOMA'
  else
  begin
    while 1 = 1
    begin
      select @p = min(POSITION) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG = 'X' and POSITION > @p and FIELDNAME not like '.%' and FIELDNAME <> @l
      if @p is null break
      select @f = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and POSITION = @p
      select @j = @j + ' and s."' + @f + '" = e."' + @f + '"'
      select @k = @k + case when @k = '' then '' else ' + ''|'' + ' end + 'isnull(rtrim(convert(varchar(100),s."' + @f + '")),'''')'
    end
    select @p = ''
    while 1 = 1
    begin
      select @p = min(POSITION) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG <> 'X' and INTTYPE = 'C' and POSITION > @p and FIELDNAME not like '.%'
      if @p is null break
      select @f = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and POSITION = @p
      select @d = @d + case when @d = '' then '' else ' or ' end + 's."' + @f + '" <> e."' + @f + '"'
      select @sql = 'select convert(varchar(290), ''#' + @t + '#'' + ' + @k + ' + ''#' + @f + '#S#'' + isnull(rtrim(s."' + @f + '"),'''')) k from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and s."' + @f + '" <> e."' + @f + '"'
       + ' union all select convert(varchar(290), ''#' + @t + '#'' + ' + @k + ' + ''#' + @f + '#E#'' + isnull(rtrim(e."' + @f + '"),'''')) k from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and s."' + @f + '" <> e."' + @f + '"'
      exec (@sql)
    end
    if @d = '' select @d = '1 = 0'
    select @sql = 'select ''#RESUMEN#' + @t + '#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock where s."' + @l + '" = ''S''))'
     + ' + ''#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock where s."' + @l + '" = ''S'' and not exists (select 1 from BAS.SAPSR3."' + @t + '" e noholdlock where e."' + @l + '" = ''E''' + @j + ')))'
     + ' + ''#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and (' + @d + ')))'
    exec (@sql)
  end
end
go
declare @t varchar(30), @l varchar(30), @p varchar(4), @f varchar(30), @j varchar(2000), @k varchar(2000), @d varchar(3000), @sql varchar(8000)
select @t = 'T082AVIEW0T', @j = '', @k = '', @d = '', @p = '', @l = null
if object_id('BAS.SAPSR3.T082AVIEW0T') is null
begin
  select '#T082AVIEW0T#NO_ES_TABLA_TRANSPARENTE'
end
else
begin
  select @l = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG = 'X' and DATATYPE = 'LANG'
  if @l is null select '#T082AVIEW0T#SIN_CAMPO_IDIOMA'
  else
  begin
    while 1 = 1
    begin
      select @p = min(POSITION) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG = 'X' and POSITION > @p and FIELDNAME not like '.%' and FIELDNAME <> @l
      if @p is null break
      select @f = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and POSITION = @p
      select @j = @j + ' and s."' + @f + '" = e."' + @f + '"'
      select @k = @k + case when @k = '' then '' else ' + ''|'' + ' end + 'isnull(rtrim(convert(varchar(100),s."' + @f + '")),'''')'
    end
    select @p = ''
    while 1 = 1
    begin
      select @p = min(POSITION) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG <> 'X' and INTTYPE = 'C' and POSITION > @p and FIELDNAME not like '.%'
      if @p is null break
      select @f = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and POSITION = @p
      select @d = @d + case when @d = '' then '' else ' or ' end + 's."' + @f + '" <> e."' + @f + '"'
      select @sql = 'select convert(varchar(290), ''#' + @t + '#'' + ' + @k + ' + ''#' + @f + '#S#'' + isnull(rtrim(s."' + @f + '"),'''')) k from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and s."' + @f + '" <> e."' + @f + '"'
       + ' union all select convert(varchar(290), ''#' + @t + '#'' + ' + @k + ' + ''#' + @f + '#E#'' + isnull(rtrim(e."' + @f + '"),'''')) k from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and s."' + @f + '" <> e."' + @f + '"'
      exec (@sql)
    end
    if @d = '' select @d = '1 = 0'
    select @sql = 'select ''#RESUMEN#' + @t + '#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock where s."' + @l + '" = ''S''))'
     + ' + ''#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock where s."' + @l + '" = ''S'' and not exists (select 1 from BAS.SAPSR3."' + @t + '" e noholdlock where e."' + @l + '" = ''E''' + @j + ')))'
     + ' + ''#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and (' + @d + ')))'
    exec (@sql)
  end
end
go
declare @t varchar(30), @l varchar(30), @p varchar(4), @f varchar(30), @j varchar(2000), @k varchar(2000), @d varchar(3000), @sql varchar(8000)
select @t = 'T082T', @j = '', @k = '', @d = '', @p = '', @l = null
if object_id('BAS.SAPSR3.T082T') is null
begin
  select '#T082T#NO_ES_TABLA_TRANSPARENTE'
end
else
begin
  select @l = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG = 'X' and DATATYPE = 'LANG'
  if @l is null select '#T082T#SIN_CAMPO_IDIOMA'
  else
  begin
    while 1 = 1
    begin
      select @p = min(POSITION) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG = 'X' and POSITION > @p and FIELDNAME not like '.%' and FIELDNAME <> @l
      if @p is null break
      select @f = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and POSITION = @p
      select @j = @j + ' and s."' + @f + '" = e."' + @f + '"'
      select @k = @k + case when @k = '' then '' else ' + ''|'' + ' end + 'isnull(rtrim(convert(varchar(100),s."' + @f + '")),'''')'
    end
    select @p = ''
    while 1 = 1
    begin
      select @p = min(POSITION) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG <> 'X' and INTTYPE = 'C' and POSITION > @p and FIELDNAME not like '.%'
      if @p is null break
      select @f = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and POSITION = @p
      select @d = @d + case when @d = '' then '' else ' or ' end + 's."' + @f + '" <> e."' + @f + '"'
      select @sql = 'select convert(varchar(290), ''#' + @t + '#'' + ' + @k + ' + ''#' + @f + '#S#'' + isnull(rtrim(s."' + @f + '"),'''')) k from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and s."' + @f + '" <> e."' + @f + '"'
       + ' union all select convert(varchar(290), ''#' + @t + '#'' + ' + @k + ' + ''#' + @f + '#E#'' + isnull(rtrim(e."' + @f + '"),'''')) k from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and s."' + @f + '" <> e."' + @f + '"'
      exec (@sql)
    end
    if @d = '' select @d = '1 = 0'
    select @sql = 'select ''#RESUMEN#' + @t + '#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock where s."' + @l + '" = ''S''))'
     + ' + ''#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock where s."' + @l + '" = ''S'' and not exists (select 1 from BAS.SAPSR3."' + @t + '" e noholdlock where e."' + @l + '" = ''E''' + @j + ')))'
     + ' + ''#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and (' + @d + ')))'
    exec (@sql)
  end
end
go
declare @t varchar(30), @l varchar(30), @p varchar(4), @f varchar(30), @j varchar(2000), @k varchar(2000), @d varchar(3000), @sql varchar(8000)
select @t = 'T090NAT', @j = '', @k = '', @d = '', @p = '', @l = null
if object_id('BAS.SAPSR3.T090NAT') is null
begin
  select '#T090NAT#NO_ES_TABLA_TRANSPARENTE'
end
else
begin
  select @l = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG = 'X' and DATATYPE = 'LANG'
  if @l is null select '#T090NAT#SIN_CAMPO_IDIOMA'
  else
  begin
    while 1 = 1
    begin
      select @p = min(POSITION) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG = 'X' and POSITION > @p and FIELDNAME not like '.%' and FIELDNAME <> @l
      if @p is null break
      select @f = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and POSITION = @p
      select @j = @j + ' and s."' + @f + '" = e."' + @f + '"'
      select @k = @k + case when @k = '' then '' else ' + ''|'' + ' end + 'isnull(rtrim(convert(varchar(100),s."' + @f + '")),'''')'
    end
    select @p = ''
    while 1 = 1
    begin
      select @p = min(POSITION) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG <> 'X' and INTTYPE = 'C' and POSITION > @p and FIELDNAME not like '.%'
      if @p is null break
      select @f = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and POSITION = @p
      select @d = @d + case when @d = '' then '' else ' or ' end + 's."' + @f + '" <> e."' + @f + '"'
      select @sql = 'select convert(varchar(290), ''#' + @t + '#'' + ' + @k + ' + ''#' + @f + '#S#'' + isnull(rtrim(s."' + @f + '"),'''')) k from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and s."' + @f + '" <> e."' + @f + '"'
       + ' union all select convert(varchar(290), ''#' + @t + '#'' + ' + @k + ' + ''#' + @f + '#E#'' + isnull(rtrim(e."' + @f + '"),'''')) k from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and s."' + @f + '" <> e."' + @f + '"'
      exec (@sql)
    end
    if @d = '' select @d = '1 = 0'
    select @sql = 'select ''#RESUMEN#' + @t + '#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock where s."' + @l + '" = ''S''))'
     + ' + ''#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock where s."' + @l + '" = ''S'' and not exists (select 1 from BAS.SAPSR3."' + @t + '" e noholdlock where e."' + @l + '" = ''E''' + @j + ')))'
     + ' + ''#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and (' + @d + ')))'
    exec (@sql)
  end
end
go
declare @t varchar(30), @l varchar(30), @p varchar(4), @f varchar(30), @j varchar(2000), @k varchar(2000), @d varchar(3000), @sql varchar(8000)
select @t = 'T090NRT', @j = '', @k = '', @d = '', @p = '', @l = null
if object_id('BAS.SAPSR3.T090NRT') is null
begin
  select '#T090NRT#NO_ES_TABLA_TRANSPARENTE'
end
else
begin
  select @l = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG = 'X' and DATATYPE = 'LANG'
  if @l is null select '#T090NRT#SIN_CAMPO_IDIOMA'
  else
  begin
    while 1 = 1
    begin
      select @p = min(POSITION) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG = 'X' and POSITION > @p and FIELDNAME not like '.%' and FIELDNAME <> @l
      if @p is null break
      select @f = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and POSITION = @p
      select @j = @j + ' and s."' + @f + '" = e."' + @f + '"'
      select @k = @k + case when @k = '' then '' else ' + ''|'' + ' end + 'isnull(rtrim(convert(varchar(100),s."' + @f + '")),'''')'
    end
    select @p = ''
    while 1 = 1
    begin
      select @p = min(POSITION) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG <> 'X' and INTTYPE = 'C' and POSITION > @p and FIELDNAME not like '.%'
      if @p is null break
      select @f = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and POSITION = @p
      select @d = @d + case when @d = '' then '' else ' or ' end + 's."' + @f + '" <> e."' + @f + '"'
      select @sql = 'select convert(varchar(290), ''#' + @t + '#'' + ' + @k + ' + ''#' + @f + '#S#'' + isnull(rtrim(s."' + @f + '"),'''')) k from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and s."' + @f + '" <> e."' + @f + '"'
       + ' union all select convert(varchar(290), ''#' + @t + '#'' + ' + @k + ' + ''#' + @f + '#E#'' + isnull(rtrim(e."' + @f + '"),'''')) k from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and s."' + @f + '" <> e."' + @f + '"'
      exec (@sql)
    end
    if @d = '' select @d = '1 = 0'
    select @sql = 'select ''#RESUMEN#' + @t + '#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock where s."' + @l + '" = ''S''))'
     + ' + ''#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock where s."' + @l + '" = ''S'' and not exists (select 1 from BAS.SAPSR3."' + @t + '" e noholdlock where e."' + @l + '" = ''E''' + @j + ')))'
     + ' + ''#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and (' + @d + ')))'
    exec (@sql)
  end
end
go
declare @t varchar(30), @l varchar(30), @p varchar(4), @f varchar(30), @j varchar(2000), @k varchar(2000), @d varchar(3000), @sql varchar(8000)
select @t = 'T090S', @j = '', @k = '', @d = '', @p = '', @l = null
if object_id('BAS.SAPSR3.T090S') is null
begin
  select '#T090S#NO_ES_TABLA_TRANSPARENTE'
end
else
begin
  select @l = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG = 'X' and DATATYPE = 'LANG'
  if @l is null select '#T090S#SIN_CAMPO_IDIOMA'
  else
  begin
    while 1 = 1
    begin
      select @p = min(POSITION) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG = 'X' and POSITION > @p and FIELDNAME not like '.%' and FIELDNAME <> @l
      if @p is null break
      select @f = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and POSITION = @p
      select @j = @j + ' and s."' + @f + '" = e."' + @f + '"'
      select @k = @k + case when @k = '' then '' else ' + ''|'' + ' end + 'isnull(rtrim(convert(varchar(100),s."' + @f + '")),'''')'
    end
    select @p = ''
    while 1 = 1
    begin
      select @p = min(POSITION) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG <> 'X' and INTTYPE = 'C' and POSITION > @p and FIELDNAME not like '.%'
      if @p is null break
      select @f = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and POSITION = @p
      select @d = @d + case when @d = '' then '' else ' or ' end + 's."' + @f + '" <> e."' + @f + '"'
      select @sql = 'select convert(varchar(290), ''#' + @t + '#'' + ' + @k + ' + ''#' + @f + '#S#'' + isnull(rtrim(s."' + @f + '"),'''')) k from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and s."' + @f + '" <> e."' + @f + '"'
       + ' union all select convert(varchar(290), ''#' + @t + '#'' + ' + @k + ' + ''#' + @f + '#E#'' + isnull(rtrim(e."' + @f + '"),'''')) k from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and s."' + @f + '" <> e."' + @f + '"'
      exec (@sql)
    end
    if @d = '' select @d = '1 = 0'
    select @sql = 'select ''#RESUMEN#' + @t + '#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock where s."' + @l + '" = ''S''))'
     + ' + ''#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock where s."' + @l + '" = ''S'' and not exists (select 1 from BAS.SAPSR3."' + @t + '" e noholdlock where e."' + @l + '" = ''E''' + @j + ')))'
     + ' + ''#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and (' + @d + ')))'
    exec (@sql)
  end
end
go
declare @t varchar(30), @l varchar(30), @p varchar(4), @f varchar(30), @j varchar(2000), @k varchar(2000), @d varchar(3000), @sql varchar(8000)
select @t = 'T090T', @j = '', @k = '', @d = '', @p = '', @l = null
if object_id('BAS.SAPSR3.T090T') is null
begin
  select '#T090T#NO_ES_TABLA_TRANSPARENTE'
end
else
begin
  select @l = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG = 'X' and DATATYPE = 'LANG'
  if @l is null select '#T090T#SIN_CAMPO_IDIOMA'
  else
  begin
    while 1 = 1
    begin
      select @p = min(POSITION) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG = 'X' and POSITION > @p and FIELDNAME not like '.%' and FIELDNAME <> @l
      if @p is null break
      select @f = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and POSITION = @p
      select @j = @j + ' and s."' + @f + '" = e."' + @f + '"'
      select @k = @k + case when @k = '' then '' else ' + ''|'' + ' end + 'isnull(rtrim(convert(varchar(100),s."' + @f + '")),'''')'
    end
    select @p = ''
    while 1 = 1
    begin
      select @p = min(POSITION) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG <> 'X' and INTTYPE = 'C' and POSITION > @p and FIELDNAME not like '.%'
      if @p is null break
      select @f = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and POSITION = @p
      select @d = @d + case when @d = '' then '' else ' or ' end + 's."' + @f + '" <> e."' + @f + '"'
      select @sql = 'select convert(varchar(290), ''#' + @t + '#'' + ' + @k + ' + ''#' + @f + '#S#'' + isnull(rtrim(s."' + @f + '"),'''')) k from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and s."' + @f + '" <> e."' + @f + '"'
       + ' union all select convert(varchar(290), ''#' + @t + '#'' + ' + @k + ' + ''#' + @f + '#E#'' + isnull(rtrim(e."' + @f + '"),'''')) k from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and s."' + @f + '" <> e."' + @f + '"'
      exec (@sql)
    end
    if @d = '' select @d = '1 = 0'
    select @sql = 'select ''#RESUMEN#' + @t + '#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock where s."' + @l + '" = ''S''))'
     + ' + ''#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock where s."' + @l + '" = ''S'' and not exists (select 1 from BAS.SAPSR3."' + @t + '" e noholdlock where e."' + @l + '" = ''E''' + @j + ')))'
     + ' + ''#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and (' + @d + ')))'
    exec (@sql)
  end
end
go
declare @t varchar(30), @l varchar(30), @p varchar(4), @f varchar(30), @j varchar(2000), @k varchar(2000), @d varchar(3000), @sql varchar(8000)
select @t = 'T090U', @j = '', @k = '', @d = '', @p = '', @l = null
if object_id('BAS.SAPSR3.T090U') is null
begin
  select '#T090U#NO_ES_TABLA_TRANSPARENTE'
end
else
begin
  select @l = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG = 'X' and DATATYPE = 'LANG'
  if @l is null select '#T090U#SIN_CAMPO_IDIOMA'
  else
  begin
    while 1 = 1
    begin
      select @p = min(POSITION) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG = 'X' and POSITION > @p and FIELDNAME not like '.%' and FIELDNAME <> @l
      if @p is null break
      select @f = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and POSITION = @p
      select @j = @j + ' and s."' + @f + '" = e."' + @f + '"'
      select @k = @k + case when @k = '' then '' else ' + ''|'' + ' end + 'isnull(rtrim(convert(varchar(100),s."' + @f + '")),'''')'
    end
    select @p = ''
    while 1 = 1
    begin
      select @p = min(POSITION) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG <> 'X' and INTTYPE = 'C' and POSITION > @p and FIELDNAME not like '.%'
      if @p is null break
      select @f = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and POSITION = @p
      select @d = @d + case when @d = '' then '' else ' or ' end + 's."' + @f + '" <> e."' + @f + '"'
      select @sql = 'select convert(varchar(290), ''#' + @t + '#'' + ' + @k + ' + ''#' + @f + '#S#'' + isnull(rtrim(s."' + @f + '"),'''')) k from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and s."' + @f + '" <> e."' + @f + '"'
       + ' union all select convert(varchar(290), ''#' + @t + '#'' + ' + @k + ' + ''#' + @f + '#E#'' + isnull(rtrim(e."' + @f + '"),'''')) k from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and s."' + @f + '" <> e."' + @f + '"'
      exec (@sql)
    end
    if @d = '' select @d = '1 = 0'
    select @sql = 'select ''#RESUMEN#' + @t + '#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock where s."' + @l + '" = ''S''))'
     + ' + ''#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock where s."' + @l + '" = ''S'' and not exists (select 1 from BAS.SAPSR3."' + @t + '" e noholdlock where e."' + @l + '" = ''E''' + @j + ')))'
     + ' + ''#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and (' + @d + ')))'
    exec (@sql)
  end
end
go
declare @t varchar(30), @l varchar(30), @p varchar(4), @f varchar(30), @j varchar(2000), @k varchar(2000), @d varchar(3000), @sql varchar(8000)
select @t = 'T091S', @j = '', @k = '', @d = '', @p = '', @l = null
if object_id('BAS.SAPSR3.T091S') is null
begin
  select '#T091S#NO_ES_TABLA_TRANSPARENTE'
end
else
begin
  select @l = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG = 'X' and DATATYPE = 'LANG'
  if @l is null select '#T091S#SIN_CAMPO_IDIOMA'
  else
  begin
    while 1 = 1
    begin
      select @p = min(POSITION) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG = 'X' and POSITION > @p and FIELDNAME not like '.%' and FIELDNAME <> @l
      if @p is null break
      select @f = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and POSITION = @p
      select @j = @j + ' and s."' + @f + '" = e."' + @f + '"'
      select @k = @k + case when @k = '' then '' else ' + ''|'' + ' end + 'isnull(rtrim(convert(varchar(100),s."' + @f + '")),'''')'
    end
    select @p = ''
    while 1 = 1
    begin
      select @p = min(POSITION) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG <> 'X' and INTTYPE = 'C' and POSITION > @p and FIELDNAME not like '.%'
      if @p is null break
      select @f = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and POSITION = @p
      select @d = @d + case when @d = '' then '' else ' or ' end + 's."' + @f + '" <> e."' + @f + '"'
      select @sql = 'select convert(varchar(290), ''#' + @t + '#'' + ' + @k + ' + ''#' + @f + '#S#'' + isnull(rtrim(s."' + @f + '"),'''')) k from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and s."' + @f + '" <> e."' + @f + '"'
       + ' union all select convert(varchar(290), ''#' + @t + '#'' + ' + @k + ' + ''#' + @f + '#E#'' + isnull(rtrim(e."' + @f + '"),'''')) k from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and s."' + @f + '" <> e."' + @f + '"'
      exec (@sql)
    end
    if @d = '' select @d = '1 = 0'
    select @sql = 'select ''#RESUMEN#' + @t + '#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock where s."' + @l + '" = ''S''))'
     + ' + ''#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock where s."' + @l + '" = ''S'' and not exists (select 1 from BAS.SAPSR3."' + @t + '" e noholdlock where e."' + @l + '" = ''E''' + @j + ')))'
     + ' + ''#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and (' + @d + ')))'
    exec (@sql)
  end
end
go
declare @t varchar(30), @l varchar(30), @p varchar(4), @f varchar(30), @j varchar(2000), @k varchar(2000), @d varchar(3000), @sql varchar(8000)
select @t = 'T091T', @j = '', @k = '', @d = '', @p = '', @l = null
if object_id('BAS.SAPSR3.T091T') is null
begin
  select '#T091T#NO_ES_TABLA_TRANSPARENTE'
end
else
begin
  select @l = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG = 'X' and DATATYPE = 'LANG'
  if @l is null select '#T091T#SIN_CAMPO_IDIOMA'
  else
  begin
    while 1 = 1
    begin
      select @p = min(POSITION) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG = 'X' and POSITION > @p and FIELDNAME not like '.%' and FIELDNAME <> @l
      if @p is null break
      select @f = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and POSITION = @p
      select @j = @j + ' and s."' + @f + '" = e."' + @f + '"'
      select @k = @k + case when @k = '' then '' else ' + ''|'' + ' end + 'isnull(rtrim(convert(varchar(100),s."' + @f + '")),'''')'
    end
    select @p = ''
    while 1 = 1
    begin
      select @p = min(POSITION) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG <> 'X' and INTTYPE = 'C' and POSITION > @p and FIELDNAME not like '.%'
      if @p is null break
      select @f = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and POSITION = @p
      select @d = @d + case when @d = '' then '' else ' or ' end + 's."' + @f + '" <> e."' + @f + '"'
      select @sql = 'select convert(varchar(290), ''#' + @t + '#'' + ' + @k + ' + ''#' + @f + '#S#'' + isnull(rtrim(s."' + @f + '"),'''')) k from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and s."' + @f + '" <> e."' + @f + '"'
       + ' union all select convert(varchar(290), ''#' + @t + '#'' + ' + @k + ' + ''#' + @f + '#E#'' + isnull(rtrim(e."' + @f + '"),'''')) k from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and s."' + @f + '" <> e."' + @f + '"'
      exec (@sql)
    end
    if @d = '' select @d = '1 = 0'
    select @sql = 'select ''#RESUMEN#' + @t + '#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock where s."' + @l + '" = ''S''))'
     + ' + ''#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock where s."' + @l + '" = ''S'' and not exists (select 1 from BAS.SAPSR3."' + @t + '" e noholdlock where e."' + @l + '" = ''E''' + @j + ')))'
     + ' + ''#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and (' + @d + ')))'
    exec (@sql)
  end
end
go
declare @t varchar(30), @l varchar(30), @p varchar(4), @f varchar(30), @j varchar(2000), @k varchar(2000), @d varchar(3000), @sql varchar(8000)
select @t = 'T093T', @j = '', @k = '', @d = '', @p = '', @l = null
if object_id('BAS.SAPSR3.T093T') is null
begin
  select '#T093T#NO_ES_TABLA_TRANSPARENTE'
end
else
begin
  select @l = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG = 'X' and DATATYPE = 'LANG'
  if @l is null select '#T093T#SIN_CAMPO_IDIOMA'
  else
  begin
    while 1 = 1
    begin
      select @p = min(POSITION) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG = 'X' and POSITION > @p and FIELDNAME not like '.%' and FIELDNAME <> @l
      if @p is null break
      select @f = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and POSITION = @p
      select @j = @j + ' and s."' + @f + '" = e."' + @f + '"'
      select @k = @k + case when @k = '' then '' else ' + ''|'' + ' end + 'isnull(rtrim(convert(varchar(100),s."' + @f + '")),'''')'
    end
    select @p = ''
    while 1 = 1
    begin
      select @p = min(POSITION) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG <> 'X' and INTTYPE = 'C' and POSITION > @p and FIELDNAME not like '.%'
      if @p is null break
      select @f = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and POSITION = @p
      select @d = @d + case when @d = '' then '' else ' or ' end + 's."' + @f + '" <> e."' + @f + '"'
      select @sql = 'select convert(varchar(290), ''#' + @t + '#'' + ' + @k + ' + ''#' + @f + '#S#'' + isnull(rtrim(s."' + @f + '"),'''')) k from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and s."' + @f + '" <> e."' + @f + '"'
       + ' union all select convert(varchar(290), ''#' + @t + '#'' + ' + @k + ' + ''#' + @f + '#E#'' + isnull(rtrim(e."' + @f + '"),'''')) k from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and s."' + @f + '" <> e."' + @f + '"'
      exec (@sql)
    end
    if @d = '' select @d = '1 = 0'
    select @sql = 'select ''#RESUMEN#' + @t + '#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock where s."' + @l + '" = ''S''))'
     + ' + ''#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock where s."' + @l + '" = ''S'' and not exists (select 1 from BAS.SAPSR3."' + @t + '" e noholdlock where e."' + @l + '" = ''E''' + @j + ')))'
     + ' + ''#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and (' + @d + ')))'
    exec (@sql)
  end
end
go
declare @t varchar(30), @l varchar(30), @p varchar(4), @f varchar(30), @j varchar(2000), @k varchar(2000), @d varchar(3000), @sql varchar(8000)
select @t = 'T093_ACCOBJT', @j = '', @k = '', @d = '', @p = '', @l = null
if object_id('BAS.SAPSR3.T093_ACCOBJT') is null
begin
  select '#T093_ACCOBJT#NO_ES_TABLA_TRANSPARENTE'
end
else
begin
  select @l = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG = 'X' and DATATYPE = 'LANG'
  if @l is null select '#T093_ACCOBJT#SIN_CAMPO_IDIOMA'
  else
  begin
    while 1 = 1
    begin
      select @p = min(POSITION) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG = 'X' and POSITION > @p and FIELDNAME not like '.%' and FIELDNAME <> @l
      if @p is null break
      select @f = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and POSITION = @p
      select @j = @j + ' and s."' + @f + '" = e."' + @f + '"'
      select @k = @k + case when @k = '' then '' else ' + ''|'' + ' end + 'isnull(rtrim(convert(varchar(100),s."' + @f + '")),'''')'
    end
    select @p = ''
    while 1 = 1
    begin
      select @p = min(POSITION) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG <> 'X' and INTTYPE = 'C' and POSITION > @p and FIELDNAME not like '.%'
      if @p is null break
      select @f = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and POSITION = @p
      select @d = @d + case when @d = '' then '' else ' or ' end + 's."' + @f + '" <> e."' + @f + '"'
      select @sql = 'select convert(varchar(290), ''#' + @t + '#'' + ' + @k + ' + ''#' + @f + '#S#'' + isnull(rtrim(s."' + @f + '"),'''')) k from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and s."' + @f + '" <> e."' + @f + '"'
       + ' union all select convert(varchar(290), ''#' + @t + '#'' + ' + @k + ' + ''#' + @f + '#E#'' + isnull(rtrim(e."' + @f + '"),'''')) k from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and s."' + @f + '" <> e."' + @f + '"'
      exec (@sql)
    end
    if @d = '' select @d = '1 = 0'
    select @sql = 'select ''#RESUMEN#' + @t + '#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock where s."' + @l + '" = ''S''))'
     + ' + ''#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock where s."' + @l + '" = ''S'' and not exists (select 1 from BAS.SAPSR3."' + @t + '" e noholdlock where e."' + @l + '" = ''E''' + @j + ')))'
     + ' + ''#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and (' + @d + ')))'
    exec (@sql)
  end
end
go
declare @t varchar(30), @l varchar(30), @p varchar(4), @f varchar(30), @j varchar(2000), @k varchar(2000), @d varchar(3000), @sql varchar(8000)
select @t = 'T094S', @j = '', @k = '', @d = '', @p = '', @l = null
if object_id('BAS.SAPSR3.T094S') is null
begin
  select '#T094S#NO_ES_TABLA_TRANSPARENTE'
end
else
begin
  select @l = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG = 'X' and DATATYPE = 'LANG'
  if @l is null select '#T094S#SIN_CAMPO_IDIOMA'
  else
  begin
    while 1 = 1
    begin
      select @p = min(POSITION) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG = 'X' and POSITION > @p and FIELDNAME not like '.%' and FIELDNAME <> @l
      if @p is null break
      select @f = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and POSITION = @p
      select @j = @j + ' and s."' + @f + '" = e."' + @f + '"'
      select @k = @k + case when @k = '' then '' else ' + ''|'' + ' end + 'isnull(rtrim(convert(varchar(100),s."' + @f + '")),'''')'
    end
    select @p = ''
    while 1 = 1
    begin
      select @p = min(POSITION) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG <> 'X' and INTTYPE = 'C' and POSITION > @p and FIELDNAME not like '.%'
      if @p is null break
      select @f = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and POSITION = @p
      select @d = @d + case when @d = '' then '' else ' or ' end + 's."' + @f + '" <> e."' + @f + '"'
      select @sql = 'select convert(varchar(290), ''#' + @t + '#'' + ' + @k + ' + ''#' + @f + '#S#'' + isnull(rtrim(s."' + @f + '"),'''')) k from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and s."' + @f + '" <> e."' + @f + '"'
       + ' union all select convert(varchar(290), ''#' + @t + '#'' + ' + @k + ' + ''#' + @f + '#E#'' + isnull(rtrim(e."' + @f + '"),'''')) k from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and s."' + @f + '" <> e."' + @f + '"'
      exec (@sql)
    end
    if @d = '' select @d = '1 = 0'
    select @sql = 'select ''#RESUMEN#' + @t + '#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock where s."' + @l + '" = ''S''))'
     + ' + ''#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock where s."' + @l + '" = ''S'' and not exists (select 1 from BAS.SAPSR3."' + @t + '" e noholdlock where e."' + @l + '" = ''E''' + @j + ')))'
     + ' + ''#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and (' + @d + ')))'
    exec (@sql)
  end
end
go
declare @t varchar(30), @l varchar(30), @p varchar(4), @f varchar(30), @j varchar(2000), @k varchar(2000), @d varchar(3000), @sql varchar(8000)
select @t = 'T095T', @j = '', @k = '', @d = '', @p = '', @l = null
if object_id('BAS.SAPSR3.T095T') is null
begin
  select '#T095T#NO_ES_TABLA_TRANSPARENTE'
end
else
begin
  select @l = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG = 'X' and DATATYPE = 'LANG'
  if @l is null select '#T095T#SIN_CAMPO_IDIOMA'
  else
  begin
    while 1 = 1
    begin
      select @p = min(POSITION) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG = 'X' and POSITION > @p and FIELDNAME not like '.%' and FIELDNAME <> @l
      if @p is null break
      select @f = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and POSITION = @p
      select @j = @j + ' and s."' + @f + '" = e."' + @f + '"'
      select @k = @k + case when @k = '' then '' else ' + ''|'' + ' end + 'isnull(rtrim(convert(varchar(100),s."' + @f + '")),'''')'
    end
    select @p = ''
    while 1 = 1
    begin
      select @p = min(POSITION) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG <> 'X' and INTTYPE = 'C' and POSITION > @p and FIELDNAME not like '.%'
      if @p is null break
      select @f = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and POSITION = @p
      select @d = @d + case when @d = '' then '' else ' or ' end + 's."' + @f + '" <> e."' + @f + '"'
      select @sql = 'select convert(varchar(290), ''#' + @t + '#'' + ' + @k + ' + ''#' + @f + '#S#'' + isnull(rtrim(s."' + @f + '"),'''')) k from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and s."' + @f + '" <> e."' + @f + '"'
       + ' union all select convert(varchar(290), ''#' + @t + '#'' + ' + @k + ' + ''#' + @f + '#E#'' + isnull(rtrim(e."' + @f + '"),'''')) k from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and s."' + @f + '" <> e."' + @f + '"'
      exec (@sql)
    end
    if @d = '' select @d = '1 = 0'
    select @sql = 'select ''#RESUMEN#' + @t + '#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock where s."' + @l + '" = ''S''))'
     + ' + ''#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock where s."' + @l + '" = ''S'' and not exists (select 1 from BAS.SAPSR3."' + @t + '" e noholdlock where e."' + @l + '" = ''E''' + @j + ')))'
     + ' + ''#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and (' + @d + ')))'
    exec (@sql)
  end
end
go
declare @t varchar(30), @l varchar(30), @p varchar(4), @f varchar(30), @j varchar(2000), @k varchar(2000), @d varchar(3000), @sql varchar(8000)
select @t = 'T096T', @j = '', @k = '', @d = '', @p = '', @l = null
if object_id('BAS.SAPSR3.T096T') is null
begin
  select '#T096T#NO_ES_TABLA_TRANSPARENTE'
end
else
begin
  select @l = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG = 'X' and DATATYPE = 'LANG'
  if @l is null select '#T096T#SIN_CAMPO_IDIOMA'
  else
  begin
    while 1 = 1
    begin
      select @p = min(POSITION) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG = 'X' and POSITION > @p and FIELDNAME not like '.%' and FIELDNAME <> @l
      if @p is null break
      select @f = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and POSITION = @p
      select @j = @j + ' and s."' + @f + '" = e."' + @f + '"'
      select @k = @k + case when @k = '' then '' else ' + ''|'' + ' end + 'isnull(rtrim(convert(varchar(100),s."' + @f + '")),'''')'
    end
    select @p = ''
    while 1 = 1
    begin
      select @p = min(POSITION) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG <> 'X' and INTTYPE = 'C' and POSITION > @p and FIELDNAME not like '.%'
      if @p is null break
      select @f = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and POSITION = @p
      select @d = @d + case when @d = '' then '' else ' or ' end + 's."' + @f + '" <> e."' + @f + '"'
      select @sql = 'select convert(varchar(290), ''#' + @t + '#'' + ' + @k + ' + ''#' + @f + '#S#'' + isnull(rtrim(s."' + @f + '"),'''')) k from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and s."' + @f + '" <> e."' + @f + '"'
       + ' union all select convert(varchar(290), ''#' + @t + '#'' + ' + @k + ' + ''#' + @f + '#E#'' + isnull(rtrim(e."' + @f + '"),'''')) k from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and s."' + @f + '" <> e."' + @f + '"'
      exec (@sql)
    end
    if @d = '' select @d = '1 = 0'
    select @sql = 'select ''#RESUMEN#' + @t + '#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock where s."' + @l + '" = ''S''))'
     + ' + ''#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock where s."' + @l + '" = ''S'' and not exists (select 1 from BAS.SAPSR3."' + @t + '" e noholdlock where e."' + @l + '" = ''E''' + @j + ')))'
     + ' + ''#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and (' + @d + ')))'
    exec (@sql)
  end
end
go
declare @t varchar(30), @l varchar(30), @p varchar(4), @f varchar(30), @j varchar(2000), @k varchar(2000), @d varchar(3000), @sql varchar(8000)
select @t = 'T800T', @j = '', @k = '', @d = '', @p = '', @l = null
if object_id('BAS.SAPSR3.T800T') is null
begin
  select '#T800T#NO_ES_TABLA_TRANSPARENTE'
end
else
begin
  select @l = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG = 'X' and DATATYPE = 'LANG'
  if @l is null select '#T800T#SIN_CAMPO_IDIOMA'
  else
  begin
    while 1 = 1
    begin
      select @p = min(POSITION) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG = 'X' and POSITION > @p and FIELDNAME not like '.%' and FIELDNAME <> @l
      if @p is null break
      select @f = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and POSITION = @p
      select @j = @j + ' and s."' + @f + '" = e."' + @f + '"'
      select @k = @k + case when @k = '' then '' else ' + ''|'' + ' end + 'isnull(rtrim(convert(varchar(100),s."' + @f + '")),'''')'
    end
    select @p = ''
    while 1 = 1
    begin
      select @p = min(POSITION) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG <> 'X' and INTTYPE = 'C' and POSITION > @p and FIELDNAME not like '.%'
      if @p is null break
      select @f = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and POSITION = @p
      select @d = @d + case when @d = '' then '' else ' or ' end + 's."' + @f + '" <> e."' + @f + '"'
      select @sql = 'select convert(varchar(290), ''#' + @t + '#'' + ' + @k + ' + ''#' + @f + '#S#'' + isnull(rtrim(s."' + @f + '"),'''')) k from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and s."' + @f + '" <> e."' + @f + '"'
       + ' union all select convert(varchar(290), ''#' + @t + '#'' + ' + @k + ' + ''#' + @f + '#E#'' + isnull(rtrim(e."' + @f + '"),'''')) k from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and s."' + @f + '" <> e."' + @f + '"'
      exec (@sql)
    end
    if @d = '' select @d = '1 = 0'
    select @sql = 'select ''#RESUMEN#' + @t + '#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock where s."' + @l + '" = ''S''))'
     + ' + ''#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock where s."' + @l + '" = ''S'' and not exists (select 1 from BAS.SAPSR3."' + @t + '" e noholdlock where e."' + @l + '" = ''E''' + @j + ')))'
     + ' + ''#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and (' + @d + ')))'
    exec (@sql)
  end
end
go
declare @t varchar(30), @l varchar(30), @p varchar(4), @f varchar(30), @j varchar(2000), @k varchar(2000), @d varchar(3000), @sql varchar(8000)
select @t = 'T802T', @j = '', @k = '', @d = '', @p = '', @l = null
if object_id('BAS.SAPSR3.T802T') is null
begin
  select '#T802T#NO_ES_TABLA_TRANSPARENTE'
end
else
begin
  select @l = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG = 'X' and DATATYPE = 'LANG'
  if @l is null select '#T802T#SIN_CAMPO_IDIOMA'
  else
  begin
    while 1 = 1
    begin
      select @p = min(POSITION) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG = 'X' and POSITION > @p and FIELDNAME not like '.%' and FIELDNAME <> @l
      if @p is null break
      select @f = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and POSITION = @p
      select @j = @j + ' and s."' + @f + '" = e."' + @f + '"'
      select @k = @k + case when @k = '' then '' else ' + ''|'' + ' end + 'isnull(rtrim(convert(varchar(100),s."' + @f + '")),'''')'
    end
    select @p = ''
    while 1 = 1
    begin
      select @p = min(POSITION) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG <> 'X' and INTTYPE = 'C' and POSITION > @p and FIELDNAME not like '.%'
      if @p is null break
      select @f = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and POSITION = @p
      select @d = @d + case when @d = '' then '' else ' or ' end + 's."' + @f + '" <> e."' + @f + '"'
      select @sql = 'select convert(varchar(290), ''#' + @t + '#'' + ' + @k + ' + ''#' + @f + '#S#'' + isnull(rtrim(s."' + @f + '"),'''')) k from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and s."' + @f + '" <> e."' + @f + '"'
       + ' union all select convert(varchar(290), ''#' + @t + '#'' + ' + @k + ' + ''#' + @f + '#E#'' + isnull(rtrim(e."' + @f + '"),'''')) k from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and s."' + @f + '" <> e."' + @f + '"'
      exec (@sql)
    end
    if @d = '' select @d = '1 = 0'
    select @sql = 'select ''#RESUMEN#' + @t + '#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock where s."' + @l + '" = ''S''))'
     + ' + ''#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock where s."' + @l + '" = ''S'' and not exists (select 1 from BAS.SAPSR3."' + @t + '" e noholdlock where e."' + @l + '" = ''E''' + @j + ')))'
     + ' + ''#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and (' + @d + ')))'
    exec (@sql)
  end
end
go
declare @t varchar(30), @l varchar(30), @p varchar(4), @f varchar(30), @j varchar(2000), @k varchar(2000), @d varchar(3000), @sql varchar(8000)
select @t = 'T803T', @j = '', @k = '', @d = '', @p = '', @l = null
if object_id('BAS.SAPSR3.T803T') is null
begin
  select '#T803T#NO_ES_TABLA_TRANSPARENTE'
end
else
begin
  select @l = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG = 'X' and DATATYPE = 'LANG'
  if @l is null select '#T803T#SIN_CAMPO_IDIOMA'
  else
  begin
    while 1 = 1
    begin
      select @p = min(POSITION) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG = 'X' and POSITION > @p and FIELDNAME not like '.%' and FIELDNAME <> @l
      if @p is null break
      select @f = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and POSITION = @p
      select @j = @j + ' and s."' + @f + '" = e."' + @f + '"'
      select @k = @k + case when @k = '' then '' else ' + ''|'' + ' end + 'isnull(rtrim(convert(varchar(100),s."' + @f + '")),'''')'
    end
    select @p = ''
    while 1 = 1
    begin
      select @p = min(POSITION) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG <> 'X' and INTTYPE = 'C' and POSITION > @p and FIELDNAME not like '.%'
      if @p is null break
      select @f = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and POSITION = @p
      select @d = @d + case when @d = '' then '' else ' or ' end + 's."' + @f + '" <> e."' + @f + '"'
      select @sql = 'select convert(varchar(290), ''#' + @t + '#'' + ' + @k + ' + ''#' + @f + '#S#'' + isnull(rtrim(s."' + @f + '"),'''')) k from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and s."' + @f + '" <> e."' + @f + '"'
       + ' union all select convert(varchar(290), ''#' + @t + '#'' + ' + @k + ' + ''#' + @f + '#E#'' + isnull(rtrim(e."' + @f + '"),'''')) k from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and s."' + @f + '" <> e."' + @f + '"'
      exec (@sql)
    end
    if @d = '' select @d = '1 = 0'
    select @sql = 'select ''#RESUMEN#' + @t + '#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock where s."' + @l + '" = ''S''))'
     + ' + ''#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock where s."' + @l + '" = ''S'' and not exists (select 1 from BAS.SAPSR3."' + @t + '" e noholdlock where e."' + @l + '" = ''E''' + @j + ')))'
     + ' + ''#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and (' + @d + ')))'
    exec (@sql)
  end
end
go
declare @t varchar(30), @l varchar(30), @p varchar(4), @f varchar(30), @j varchar(2000), @k varchar(2000), @d varchar(3000), @sql varchar(8000)
select @t = 'T804BT', @j = '', @k = '', @d = '', @p = '', @l = null
if object_id('BAS.SAPSR3.T804BT') is null
begin
  select '#T804BT#NO_ES_TABLA_TRANSPARENTE'
end
else
begin
  select @l = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG = 'X' and DATATYPE = 'LANG'
  if @l is null select '#T804BT#SIN_CAMPO_IDIOMA'
  else
  begin
    while 1 = 1
    begin
      select @p = min(POSITION) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG = 'X' and POSITION > @p and FIELDNAME not like '.%' and FIELDNAME <> @l
      if @p is null break
      select @f = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and POSITION = @p
      select @j = @j + ' and s."' + @f + '" = e."' + @f + '"'
      select @k = @k + case when @k = '' then '' else ' + ''|'' + ' end + 'isnull(rtrim(convert(varchar(100),s."' + @f + '")),'''')'
    end
    select @p = ''
    while 1 = 1
    begin
      select @p = min(POSITION) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG <> 'X' and INTTYPE = 'C' and POSITION > @p and FIELDNAME not like '.%'
      if @p is null break
      select @f = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and POSITION = @p
      select @d = @d + case when @d = '' then '' else ' or ' end + 's."' + @f + '" <> e."' + @f + '"'
      select @sql = 'select convert(varchar(290), ''#' + @t + '#'' + ' + @k + ' + ''#' + @f + '#S#'' + isnull(rtrim(s."' + @f + '"),'''')) k from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and s."' + @f + '" <> e."' + @f + '"'
       + ' union all select convert(varchar(290), ''#' + @t + '#'' + ' + @k + ' + ''#' + @f + '#E#'' + isnull(rtrim(e."' + @f + '"),'''')) k from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and s."' + @f + '" <> e."' + @f + '"'
      exec (@sql)
    end
    if @d = '' select @d = '1 = 0'
    select @sql = 'select ''#RESUMEN#' + @t + '#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock where s."' + @l + '" = ''S''))'
     + ' + ''#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock where s."' + @l + '" = ''S'' and not exists (select 1 from BAS.SAPSR3."' + @t + '" e noholdlock where e."' + @l + '" = ''E''' + @j + ')))'
     + ' + ''#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and (' + @d + ')))'
    exec (@sql)
  end
end
go
declare @t varchar(30), @l varchar(30), @p varchar(4), @f varchar(30), @j varchar(2000), @k varchar(2000), @d varchar(3000), @sql varchar(8000)
select @t = 'T804T', @j = '', @k = '', @d = '', @p = '', @l = null
if object_id('BAS.SAPSR3.T804T') is null
begin
  select '#T804T#NO_ES_TABLA_TRANSPARENTE'
end
else
begin
  select @l = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG = 'X' and DATATYPE = 'LANG'
  if @l is null select '#T804T#SIN_CAMPO_IDIOMA'
  else
  begin
    while 1 = 1
    begin
      select @p = min(POSITION) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG = 'X' and POSITION > @p and FIELDNAME not like '.%' and FIELDNAME <> @l
      if @p is null break
      select @f = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and POSITION = @p
      select @j = @j + ' and s."' + @f + '" = e."' + @f + '"'
      select @k = @k + case when @k = '' then '' else ' + ''|'' + ' end + 'isnull(rtrim(convert(varchar(100),s."' + @f + '")),'''')'
    end
    select @p = ''
    while 1 = 1
    begin
      select @p = min(POSITION) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG <> 'X' and INTTYPE = 'C' and POSITION > @p and FIELDNAME not like '.%'
      if @p is null break
      select @f = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and POSITION = @p
      select @d = @d + case when @d = '' then '' else ' or ' end + 's."' + @f + '" <> e."' + @f + '"'
      select @sql = 'select convert(varchar(290), ''#' + @t + '#'' + ' + @k + ' + ''#' + @f + '#S#'' + isnull(rtrim(s."' + @f + '"),'''')) k from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and s."' + @f + '" <> e."' + @f + '"'
       + ' union all select convert(varchar(290), ''#' + @t + '#'' + ' + @k + ' + ''#' + @f + '#E#'' + isnull(rtrim(e."' + @f + '"),'''')) k from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and s."' + @f + '" <> e."' + @f + '"'
      exec (@sql)
    end
    if @d = '' select @d = '1 = 0'
    select @sql = 'select ''#RESUMEN#' + @t + '#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock where s."' + @l + '" = ''S''))'
     + ' + ''#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock where s."' + @l + '" = ''S'' and not exists (select 1 from BAS.SAPSR3."' + @t + '" e noholdlock where e."' + @l + '" = ''E''' + @j + ')))'
     + ' + ''#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and (' + @d + ')))'
    exec (@sql)
  end
end
go
declare @t varchar(30), @l varchar(30), @p varchar(4), @f varchar(30), @j varchar(2000), @k varchar(2000), @d varchar(3000), @sql varchar(8000)
select @t = 'T807T', @j = '', @k = '', @d = '', @p = '', @l = null
if object_id('BAS.SAPSR3.T807T') is null
begin
  select '#T807T#NO_ES_TABLA_TRANSPARENTE'
end
else
begin
  select @l = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG = 'X' and DATATYPE = 'LANG'
  if @l is null select '#T807T#SIN_CAMPO_IDIOMA'
  else
  begin
    while 1 = 1
    begin
      select @p = min(POSITION) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG = 'X' and POSITION > @p and FIELDNAME not like '.%' and FIELDNAME <> @l
      if @p is null break
      select @f = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and POSITION = @p
      select @j = @j + ' and s."' + @f + '" = e."' + @f + '"'
      select @k = @k + case when @k = '' then '' else ' + ''|'' + ' end + 'isnull(rtrim(convert(varchar(100),s."' + @f + '")),'''')'
    end
    select @p = ''
    while 1 = 1
    begin
      select @p = min(POSITION) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG <> 'X' and INTTYPE = 'C' and POSITION > @p and FIELDNAME not like '.%'
      if @p is null break
      select @f = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and POSITION = @p
      select @d = @d + case when @d = '' then '' else ' or ' end + 's."' + @f + '" <> e."' + @f + '"'
      select @sql = 'select convert(varchar(290), ''#' + @t + '#'' + ' + @k + ' + ''#' + @f + '#S#'' + isnull(rtrim(s."' + @f + '"),'''')) k from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and s."' + @f + '" <> e."' + @f + '"'
       + ' union all select convert(varchar(290), ''#' + @t + '#'' + ' + @k + ' + ''#' + @f + '#E#'' + isnull(rtrim(e."' + @f + '"),'''')) k from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and s."' + @f + '" <> e."' + @f + '"'
      exec (@sql)
    end
    if @d = '' select @d = '1 = 0'
    select @sql = 'select ''#RESUMEN#' + @t + '#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock where s."' + @l + '" = ''S''))'
     + ' + ''#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock where s."' + @l + '" = ''S'' and not exists (select 1 from BAS.SAPSR3."' + @t + '" e noholdlock where e."' + @l + '" = ''E''' + @j + ')))'
     + ' + ''#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and (' + @d + ')))'
    exec (@sql)
  end
end
go
declare @t varchar(30), @l varchar(30), @p varchar(4), @f varchar(30), @j varchar(2000), @k varchar(2000), @d varchar(3000), @sql varchar(8000)
select @t = 'T80DT', @j = '', @k = '', @d = '', @p = '', @l = null
if object_id('BAS.SAPSR3.T80DT') is null
begin
  select '#T80DT#NO_ES_TABLA_TRANSPARENTE'
end
else
begin
  select @l = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG = 'X' and DATATYPE = 'LANG'
  if @l is null select '#T80DT#SIN_CAMPO_IDIOMA'
  else
  begin
    while 1 = 1
    begin
      select @p = min(POSITION) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG = 'X' and POSITION > @p and FIELDNAME not like '.%' and FIELDNAME <> @l
      if @p is null break
      select @f = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and POSITION = @p
      select @j = @j + ' and s."' + @f + '" = e."' + @f + '"'
      select @k = @k + case when @k = '' then '' else ' + ''|'' + ' end + 'isnull(rtrim(convert(varchar(100),s."' + @f + '")),'''')'
    end
    select @p = ''
    while 1 = 1
    begin
      select @p = min(POSITION) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG <> 'X' and INTTYPE = 'C' and POSITION > @p and FIELDNAME not like '.%'
      if @p is null break
      select @f = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and POSITION = @p
      select @d = @d + case when @d = '' then '' else ' or ' end + 's."' + @f + '" <> e."' + @f + '"'
      select @sql = 'select convert(varchar(290), ''#' + @t + '#'' + ' + @k + ' + ''#' + @f + '#S#'' + isnull(rtrim(s."' + @f + '"),'''')) k from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and s."' + @f + '" <> e."' + @f + '"'
       + ' union all select convert(varchar(290), ''#' + @t + '#'' + ' + @k + ' + ''#' + @f + '#E#'' + isnull(rtrim(e."' + @f + '"),'''')) k from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and s."' + @f + '" <> e."' + @f + '"'
      exec (@sql)
    end
    if @d = '' select @d = '1 = 0'
    select @sql = 'select ''#RESUMEN#' + @t + '#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock where s."' + @l + '" = ''S''))'
     + ' + ''#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock where s."' + @l + '" = ''S'' and not exists (select 1 from BAS.SAPSR3."' + @t + '" e noholdlock where e."' + @l + '" = ''E''' + @j + ')))'
     + ' + ''#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and (' + @d + ')))'
    exec (@sql)
  end
end
go
declare @t varchar(30), @l varchar(30), @p varchar(4), @f varchar(30), @j varchar(2000), @k varchar(2000), @d varchar(3000), @sql varchar(8000)
select @t = 'T80IT', @j = '', @k = '', @d = '', @p = '', @l = null
if object_id('BAS.SAPSR3.T80IT') is null
begin
  select '#T80IT#NO_ES_TABLA_TRANSPARENTE'
end
else
begin
  select @l = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG = 'X' and DATATYPE = 'LANG'
  if @l is null select '#T80IT#SIN_CAMPO_IDIOMA'
  else
  begin
    while 1 = 1
    begin
      select @p = min(POSITION) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG = 'X' and POSITION > @p and FIELDNAME not like '.%' and FIELDNAME <> @l
      if @p is null break
      select @f = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and POSITION = @p
      select @j = @j + ' and s."' + @f + '" = e."' + @f + '"'
      select @k = @k + case when @k = '' then '' else ' + ''|'' + ' end + 'isnull(rtrim(convert(varchar(100),s."' + @f + '")),'''')'
    end
    select @p = ''
    while 1 = 1
    begin
      select @p = min(POSITION) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG <> 'X' and INTTYPE = 'C' and POSITION > @p and FIELDNAME not like '.%'
      if @p is null break
      select @f = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and POSITION = @p
      select @d = @d + case when @d = '' then '' else ' or ' end + 's."' + @f + '" <> e."' + @f + '"'
      select @sql = 'select convert(varchar(290), ''#' + @t + '#'' + ' + @k + ' + ''#' + @f + '#S#'' + isnull(rtrim(s."' + @f + '"),'''')) k from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and s."' + @f + '" <> e."' + @f + '"'
       + ' union all select convert(varchar(290), ''#' + @t + '#'' + ' + @k + ' + ''#' + @f + '#E#'' + isnull(rtrim(e."' + @f + '"),'''')) k from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and s."' + @f + '" <> e."' + @f + '"'
      exec (@sql)
    end
    if @d = '' select @d = '1 = 0'
    select @sql = 'select ''#RESUMEN#' + @t + '#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock where s."' + @l + '" = ''S''))'
     + ' + ''#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock where s."' + @l + '" = ''S'' and not exists (select 1 from BAS.SAPSR3."' + @t + '" e noholdlock where e."' + @l + '" = ''E''' + @j + ')))'
     + ' + ''#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and (' + @d + ')))'
    exec (@sql)
  end
end
go
declare @t varchar(30), @l varchar(30), @p varchar(4), @f varchar(30), @j varchar(2000), @k varchar(2000), @d varchar(3000), @sql varchar(8000)
select @t = 'T856T', @j = '', @k = '', @d = '', @p = '', @l = null
if object_id('BAS.SAPSR3.T856T') is null
begin
  select '#T856T#NO_ES_TABLA_TRANSPARENTE'
end
else
begin
  select @l = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG = 'X' and DATATYPE = 'LANG'
  if @l is null select '#T856T#SIN_CAMPO_IDIOMA'
  else
  begin
    while 1 = 1
    begin
      select @p = min(POSITION) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG = 'X' and POSITION > @p and FIELDNAME not like '.%' and FIELDNAME <> @l
      if @p is null break
      select @f = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and POSITION = @p
      select @j = @j + ' and s."' + @f + '" = e."' + @f + '"'
      select @k = @k + case when @k = '' then '' else ' + ''|'' + ' end + 'isnull(rtrim(convert(varchar(100),s."' + @f + '")),'''')'
    end
    select @p = ''
    while 1 = 1
    begin
      select @p = min(POSITION) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG <> 'X' and INTTYPE = 'C' and POSITION > @p and FIELDNAME not like '.%'
      if @p is null break
      select @f = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and POSITION = @p
      select @d = @d + case when @d = '' then '' else ' or ' end + 's."' + @f + '" <> e."' + @f + '"'
      select @sql = 'select convert(varchar(290), ''#' + @t + '#'' + ' + @k + ' + ''#' + @f + '#S#'' + isnull(rtrim(s."' + @f + '"),'''')) k from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and s."' + @f + '" <> e."' + @f + '"'
       + ' union all select convert(varchar(290), ''#' + @t + '#'' + ' + @k + ' + ''#' + @f + '#E#'' + isnull(rtrim(e."' + @f + '"),'''')) k from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and s."' + @f + '" <> e."' + @f + '"'
      exec (@sql)
    end
    if @d = '' select @d = '1 = 0'
    select @sql = 'select ''#RESUMEN#' + @t + '#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock where s."' + @l + '" = ''S''))'
     + ' + ''#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock where s."' + @l + '" = ''S'' and not exists (select 1 from BAS.SAPSR3."' + @t + '" e noholdlock where e."' + @l + '" = ''E''' + @j + ')))'
     + ' + ''#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and (' + @d + ')))'
    exec (@sql)
  end
end
go
declare @t varchar(30), @l varchar(30), @p varchar(4), @f varchar(30), @j varchar(2000), @k varchar(2000), @d varchar(3000), @sql varchar(8000)
select @t = 'T857T', @j = '', @k = '', @d = '', @p = '', @l = null
if object_id('BAS.SAPSR3.T857T') is null
begin
  select '#T857T#NO_ES_TABLA_TRANSPARENTE'
end
else
begin
  select @l = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG = 'X' and DATATYPE = 'LANG'
  if @l is null select '#T857T#SIN_CAMPO_IDIOMA'
  else
  begin
    while 1 = 1
    begin
      select @p = min(POSITION) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG = 'X' and POSITION > @p and FIELDNAME not like '.%' and FIELDNAME <> @l
      if @p is null break
      select @f = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and POSITION = @p
      select @j = @j + ' and s."' + @f + '" = e."' + @f + '"'
      select @k = @k + case when @k = '' then '' else ' + ''|'' + ' end + 'isnull(rtrim(convert(varchar(100),s."' + @f + '")),'''')'
    end
    select @p = ''
    while 1 = 1
    begin
      select @p = min(POSITION) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG <> 'X' and INTTYPE = 'C' and POSITION > @p and FIELDNAME not like '.%'
      if @p is null break
      select @f = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and POSITION = @p
      select @d = @d + case when @d = '' then '' else ' or ' end + 's."' + @f + '" <> e."' + @f + '"'
      select @sql = 'select convert(varchar(290), ''#' + @t + '#'' + ' + @k + ' + ''#' + @f + '#S#'' + isnull(rtrim(s."' + @f + '"),'''')) k from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and s."' + @f + '" <> e."' + @f + '"'
       + ' union all select convert(varchar(290), ''#' + @t + '#'' + ' + @k + ' + ''#' + @f + '#E#'' + isnull(rtrim(e."' + @f + '"),'''')) k from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and s."' + @f + '" <> e."' + @f + '"'
      exec (@sql)
    end
    if @d = '' select @d = '1 = 0'
    select @sql = 'select ''#RESUMEN#' + @t + '#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock where s."' + @l + '" = ''S''))'
     + ' + ''#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock where s."' + @l + '" = ''S'' and not exists (select 1 from BAS.SAPSR3."' + @t + '" e noholdlock where e."' + @l + '" = ''E''' + @j + ')))'
     + ' + ''#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and (' + @d + ')))'
    exec (@sql)
  end
end
go
declare @t varchar(30), @l varchar(30), @p varchar(4), @f varchar(30), @j varchar(2000), @k varchar(2000), @d varchar(3000), @sql varchar(8000)
select @t = 'T858T', @j = '', @k = '', @d = '', @p = '', @l = null
if object_id('BAS.SAPSR3.T858T') is null
begin
  select '#T858T#NO_ES_TABLA_TRANSPARENTE'
end
else
begin
  select @l = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG = 'X' and DATATYPE = 'LANG'
  if @l is null select '#T858T#SIN_CAMPO_IDIOMA'
  else
  begin
    while 1 = 1
    begin
      select @p = min(POSITION) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG = 'X' and POSITION > @p and FIELDNAME not like '.%' and FIELDNAME <> @l
      if @p is null break
      select @f = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and POSITION = @p
      select @j = @j + ' and s."' + @f + '" = e."' + @f + '"'
      select @k = @k + case when @k = '' then '' else ' + ''|'' + ' end + 'isnull(rtrim(convert(varchar(100),s."' + @f + '")),'''')'
    end
    select @p = ''
    while 1 = 1
    begin
      select @p = min(POSITION) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG <> 'X' and INTTYPE = 'C' and POSITION > @p and FIELDNAME not like '.%'
      if @p is null break
      select @f = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and POSITION = @p
      select @d = @d + case when @d = '' then '' else ' or ' end + 's."' + @f + '" <> e."' + @f + '"'
      select @sql = 'select convert(varchar(290), ''#' + @t + '#'' + ' + @k + ' + ''#' + @f + '#S#'' + isnull(rtrim(s."' + @f + '"),'''')) k from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and s."' + @f + '" <> e."' + @f + '"'
       + ' union all select convert(varchar(290), ''#' + @t + '#'' + ' + @k + ' + ''#' + @f + '#E#'' + isnull(rtrim(e."' + @f + '"),'''')) k from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and s."' + @f + '" <> e."' + @f + '"'
      exec (@sql)
    end
    if @d = '' select @d = '1 = 0'
    select @sql = 'select ''#RESUMEN#' + @t + '#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock where s."' + @l + '" = ''S''))'
     + ' + ''#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock where s."' + @l + '" = ''S'' and not exists (select 1 from BAS.SAPSR3."' + @t + '" e noholdlock where e."' + @l + '" = ''E''' + @j + ')))'
     + ' + ''#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and (' + @d + ')))'
    exec (@sql)
  end
end
go
declare @t varchar(30), @l varchar(30), @p varchar(4), @f varchar(30), @j varchar(2000), @k varchar(2000), @d varchar(3000), @sql varchar(8000)
select @t = 'T881T', @j = '', @k = '', @d = '', @p = '', @l = null
if object_id('BAS.SAPSR3.T881T') is null
begin
  select '#T881T#NO_ES_TABLA_TRANSPARENTE'
end
else
begin
  select @l = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG = 'X' and DATATYPE = 'LANG'
  if @l is null select '#T881T#SIN_CAMPO_IDIOMA'
  else
  begin
    while 1 = 1
    begin
      select @p = min(POSITION) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG = 'X' and POSITION > @p and FIELDNAME not like '.%' and FIELDNAME <> @l
      if @p is null break
      select @f = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and POSITION = @p
      select @j = @j + ' and s."' + @f + '" = e."' + @f + '"'
      select @k = @k + case when @k = '' then '' else ' + ''|'' + ' end + 'isnull(rtrim(convert(varchar(100),s."' + @f + '")),'''')'
    end
    select @p = ''
    while 1 = 1
    begin
      select @p = min(POSITION) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG <> 'X' and INTTYPE = 'C' and POSITION > @p and FIELDNAME not like '.%'
      if @p is null break
      select @f = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and POSITION = @p
      select @d = @d + case when @d = '' then '' else ' or ' end + 's."' + @f + '" <> e."' + @f + '"'
      select @sql = 'select convert(varchar(290), ''#' + @t + '#'' + ' + @k + ' + ''#' + @f + '#S#'' + isnull(rtrim(s."' + @f + '"),'''')) k from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and s."' + @f + '" <> e."' + @f + '"'
       + ' union all select convert(varchar(290), ''#' + @t + '#'' + ' + @k + ' + ''#' + @f + '#E#'' + isnull(rtrim(e."' + @f + '"),'''')) k from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and s."' + @f + '" <> e."' + @f + '"'
      exec (@sql)
    end
    if @d = '' select @d = '1 = 0'
    select @sql = 'select ''#RESUMEN#' + @t + '#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock where s."' + @l + '" = ''S''))'
     + ' + ''#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock where s."' + @l + '" = ''S'' and not exists (select 1 from BAS.SAPSR3."' + @t + '" e noholdlock where e."' + @l + '" = ''E''' + @j + ')))'
     + ' + ''#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and (' + @d + ')))'
    exec (@sql)
  end
end
go
declare @t varchar(30), @l varchar(30), @p varchar(4), @f varchar(30), @j varchar(2000), @k varchar(2000), @d varchar(3000), @sql varchar(8000)
select @t = 'T888T', @j = '', @k = '', @d = '', @p = '', @l = null
if object_id('BAS.SAPSR3.T888T') is null
begin
  select '#T888T#NO_ES_TABLA_TRANSPARENTE'
end
else
begin
  select @l = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG = 'X' and DATATYPE = 'LANG'
  if @l is null select '#T888T#SIN_CAMPO_IDIOMA'
  else
  begin
    while 1 = 1
    begin
      select @p = min(POSITION) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG = 'X' and POSITION > @p and FIELDNAME not like '.%' and FIELDNAME <> @l
      if @p is null break
      select @f = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and POSITION = @p
      select @j = @j + ' and s."' + @f + '" = e."' + @f + '"'
      select @k = @k + case when @k = '' then '' else ' + ''|'' + ' end + 'isnull(rtrim(convert(varchar(100),s."' + @f + '")),'''')'
    end
    select @p = ''
    while 1 = 1
    begin
      select @p = min(POSITION) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG <> 'X' and INTTYPE = 'C' and POSITION > @p and FIELDNAME not like '.%'
      if @p is null break
      select @f = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and POSITION = @p
      select @d = @d + case when @d = '' then '' else ' or ' end + 's."' + @f + '" <> e."' + @f + '"'
      select @sql = 'select convert(varchar(290), ''#' + @t + '#'' + ' + @k + ' + ''#' + @f + '#S#'' + isnull(rtrim(s."' + @f + '"),'''')) k from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and s."' + @f + '" <> e."' + @f + '"'
       + ' union all select convert(varchar(290), ''#' + @t + '#'' + ' + @k + ' + ''#' + @f + '#E#'' + isnull(rtrim(e."' + @f + '"),'''')) k from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and s."' + @f + '" <> e."' + @f + '"'
      exec (@sql)
    end
    if @d = '' select @d = '1 = 0'
    select @sql = 'select ''#RESUMEN#' + @t + '#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock where s."' + @l + '" = ''S''))'
     + ' + ''#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock where s."' + @l + '" = ''S'' and not exists (select 1 from BAS.SAPSR3."' + @t + '" e noholdlock where e."' + @l + '" = ''E''' + @j + ')))'
     + ' + ''#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and (' + @d + ')))'
    exec (@sql)
  end
end
go
declare @t varchar(30), @l varchar(30), @p varchar(4), @f varchar(30), @j varchar(2000), @k varchar(2000), @d varchar(3000), @sql varchar(8000)
select @t = 'T894T', @j = '', @k = '', @d = '', @p = '', @l = null
if object_id('BAS.SAPSR3.T894T') is null
begin
  select '#T894T#NO_ES_TABLA_TRANSPARENTE'
end
else
begin
  select @l = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG = 'X' and DATATYPE = 'LANG'
  if @l is null select '#T894T#SIN_CAMPO_IDIOMA'
  else
  begin
    while 1 = 1
    begin
      select @p = min(POSITION) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG = 'X' and POSITION > @p and FIELDNAME not like '.%' and FIELDNAME <> @l
      if @p is null break
      select @f = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and POSITION = @p
      select @j = @j + ' and s."' + @f + '" = e."' + @f + '"'
      select @k = @k + case when @k = '' then '' else ' + ''|'' + ' end + 'isnull(rtrim(convert(varchar(100),s."' + @f + '")),'''')'
    end
    select @p = ''
    while 1 = 1
    begin
      select @p = min(POSITION) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG <> 'X' and INTTYPE = 'C' and POSITION > @p and FIELDNAME not like '.%'
      if @p is null break
      select @f = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and POSITION = @p
      select @d = @d + case when @d = '' then '' else ' or ' end + 's."' + @f + '" <> e."' + @f + '"'
      select @sql = 'select convert(varchar(290), ''#' + @t + '#'' + ' + @k + ' + ''#' + @f + '#S#'' + isnull(rtrim(s."' + @f + '"),'''')) k from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and s."' + @f + '" <> e."' + @f + '"'
       + ' union all select convert(varchar(290), ''#' + @t + '#'' + ' + @k + ' + ''#' + @f + '#E#'' + isnull(rtrim(e."' + @f + '"),'''')) k from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and s."' + @f + '" <> e."' + @f + '"'
      exec (@sql)
    end
    if @d = '' select @d = '1 = 0'
    select @sql = 'select ''#RESUMEN#' + @t + '#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock where s."' + @l + '" = ''S''))'
     + ' + ''#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock where s."' + @l + '" = ''S'' and not exists (select 1 from BAS.SAPSR3."' + @t + '" e noholdlock where e."' + @l + '" = ''E''' + @j + ')))'
     + ' + ''#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and (' + @d + ')))'
    exec (@sql)
  end
end
go
declare @t varchar(30), @l varchar(30), @p varchar(4), @f varchar(30), @j varchar(2000), @k varchar(2000), @d varchar(3000), @sql varchar(8000)
select @t = 'T8G01T', @j = '', @k = '', @d = '', @p = '', @l = null
if object_id('BAS.SAPSR3.T8G01T') is null
begin
  select '#T8G01T#NO_ES_TABLA_TRANSPARENTE'
end
else
begin
  select @l = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG = 'X' and DATATYPE = 'LANG'
  if @l is null select '#T8G01T#SIN_CAMPO_IDIOMA'
  else
  begin
    while 1 = 1
    begin
      select @p = min(POSITION) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG = 'X' and POSITION > @p and FIELDNAME not like '.%' and FIELDNAME <> @l
      if @p is null break
      select @f = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and POSITION = @p
      select @j = @j + ' and s."' + @f + '" = e."' + @f + '"'
      select @k = @k + case when @k = '' then '' else ' + ''|'' + ' end + 'isnull(rtrim(convert(varchar(100),s."' + @f + '")),'''')'
    end
    select @p = ''
    while 1 = 1
    begin
      select @p = min(POSITION) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG <> 'X' and INTTYPE = 'C' and POSITION > @p and FIELDNAME not like '.%'
      if @p is null break
      select @f = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and POSITION = @p
      select @d = @d + case when @d = '' then '' else ' or ' end + 's."' + @f + '" <> e."' + @f + '"'
      select @sql = 'select convert(varchar(290), ''#' + @t + '#'' + ' + @k + ' + ''#' + @f + '#S#'' + isnull(rtrim(s."' + @f + '"),'''')) k from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and s."' + @f + '" <> e."' + @f + '"'
       + ' union all select convert(varchar(290), ''#' + @t + '#'' + ' + @k + ' + ''#' + @f + '#E#'' + isnull(rtrim(e."' + @f + '"),'''')) k from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and s."' + @f + '" <> e."' + @f + '"'
      exec (@sql)
    end
    if @d = '' select @d = '1 = 0'
    select @sql = 'select ''#RESUMEN#' + @t + '#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock where s."' + @l + '" = ''S''))'
     + ' + ''#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock where s."' + @l + '" = ''S'' and not exists (select 1 from BAS.SAPSR3."' + @t + '" e noholdlock where e."' + @l + '" = ''E''' + @j + ')))'
     + ' + ''#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and (' + @d + ')))'
    exec (@sql)
  end
end
go
declare @t varchar(30), @l varchar(30), @p varchar(4), @f varchar(30), @j varchar(2000), @k varchar(2000), @d varchar(3000), @sql varchar(8000)
select @t = 'T8G02T', @j = '', @k = '', @d = '', @p = '', @l = null
if object_id('BAS.SAPSR3.T8G02T') is null
begin
  select '#T8G02T#NO_ES_TABLA_TRANSPARENTE'
end
else
begin
  select @l = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG = 'X' and DATATYPE = 'LANG'
  if @l is null select '#T8G02T#SIN_CAMPO_IDIOMA'
  else
  begin
    while 1 = 1
    begin
      select @p = min(POSITION) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG = 'X' and POSITION > @p and FIELDNAME not like '.%' and FIELDNAME <> @l
      if @p is null break
      select @f = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and POSITION = @p
      select @j = @j + ' and s."' + @f + '" = e."' + @f + '"'
      select @k = @k + case when @k = '' then '' else ' + ''|'' + ' end + 'isnull(rtrim(convert(varchar(100),s."' + @f + '")),'''')'
    end
    select @p = ''
    while 1 = 1
    begin
      select @p = min(POSITION) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG <> 'X' and INTTYPE = 'C' and POSITION > @p and FIELDNAME not like '.%'
      if @p is null break
      select @f = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and POSITION = @p
      select @d = @d + case when @d = '' then '' else ' or ' end + 's."' + @f + '" <> e."' + @f + '"'
      select @sql = 'select convert(varchar(290), ''#' + @t + '#'' + ' + @k + ' + ''#' + @f + '#S#'' + isnull(rtrim(s."' + @f + '"),'''')) k from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and s."' + @f + '" <> e."' + @f + '"'
       + ' union all select convert(varchar(290), ''#' + @t + '#'' + ' + @k + ' + ''#' + @f + '#E#'' + isnull(rtrim(e."' + @f + '"),'''')) k from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and s."' + @f + '" <> e."' + @f + '"'
      exec (@sql)
    end
    if @d = '' select @d = '1 = 0'
    select @sql = 'select ''#RESUMEN#' + @t + '#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock where s."' + @l + '" = ''S''))'
     + ' + ''#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock where s."' + @l + '" = ''S'' and not exists (select 1 from BAS.SAPSR3."' + @t + '" e noholdlock where e."' + @l + '" = ''E''' + @j + ')))'
     + ' + ''#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and (' + @d + ')))'
    exec (@sql)
  end
end
go
declare @t varchar(30), @l varchar(30), @p varchar(4), @f varchar(30), @j varchar(2000), @k varchar(2000), @d varchar(3000), @sql varchar(8000)
select @t = 'T8G031T', @j = '', @k = '', @d = '', @p = '', @l = null
if object_id('BAS.SAPSR3.T8G031T') is null
begin
  select '#T8G031T#NO_ES_TABLA_TRANSPARENTE'
end
else
begin
  select @l = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG = 'X' and DATATYPE = 'LANG'
  if @l is null select '#T8G031T#SIN_CAMPO_IDIOMA'
  else
  begin
    while 1 = 1
    begin
      select @p = min(POSITION) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG = 'X' and POSITION > @p and FIELDNAME not like '.%' and FIELDNAME <> @l
      if @p is null break
      select @f = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and POSITION = @p
      select @j = @j + ' and s."' + @f + '" = e."' + @f + '"'
      select @k = @k + case when @k = '' then '' else ' + ''|'' + ' end + 'isnull(rtrim(convert(varchar(100),s."' + @f + '")),'''')'
    end
    select @p = ''
    while 1 = 1
    begin
      select @p = min(POSITION) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG <> 'X' and INTTYPE = 'C' and POSITION > @p and FIELDNAME not like '.%'
      if @p is null break
      select @f = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and POSITION = @p
      select @d = @d + case when @d = '' then '' else ' or ' end + 's."' + @f + '" <> e."' + @f + '"'
      select @sql = 'select convert(varchar(290), ''#' + @t + '#'' + ' + @k + ' + ''#' + @f + '#S#'' + isnull(rtrim(s."' + @f + '"),'''')) k from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and s."' + @f + '" <> e."' + @f + '"'
       + ' union all select convert(varchar(290), ''#' + @t + '#'' + ' + @k + ' + ''#' + @f + '#E#'' + isnull(rtrim(e."' + @f + '"),'''')) k from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and s."' + @f + '" <> e."' + @f + '"'
      exec (@sql)
    end
    if @d = '' select @d = '1 = 0'
    select @sql = 'select ''#RESUMEN#' + @t + '#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock where s."' + @l + '" = ''S''))'
     + ' + ''#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock where s."' + @l + '" = ''S'' and not exists (select 1 from BAS.SAPSR3."' + @t + '" e noholdlock where e."' + @l + '" = ''E''' + @j + ')))'
     + ' + ''#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and (' + @d + ')))'
    exec (@sql)
  end
end
go
declare @t varchar(30), @l varchar(30), @p varchar(4), @f varchar(30), @j varchar(2000), @k varchar(2000), @d varchar(3000), @sql varchar(8000)
select @t = 'T8G03T', @j = '', @k = '', @d = '', @p = '', @l = null
if object_id('BAS.SAPSR3.T8G03T') is null
begin
  select '#T8G03T#NO_ES_TABLA_TRANSPARENTE'
end
else
begin
  select @l = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG = 'X' and DATATYPE = 'LANG'
  if @l is null select '#T8G03T#SIN_CAMPO_IDIOMA'
  else
  begin
    while 1 = 1
    begin
      select @p = min(POSITION) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG = 'X' and POSITION > @p and FIELDNAME not like '.%' and FIELDNAME <> @l
      if @p is null break
      select @f = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and POSITION = @p
      select @j = @j + ' and s."' + @f + '" = e."' + @f + '"'
      select @k = @k + case when @k = '' then '' else ' + ''|'' + ' end + 'isnull(rtrim(convert(varchar(100),s."' + @f + '")),'''')'
    end
    select @p = ''
    while 1 = 1
    begin
      select @p = min(POSITION) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG <> 'X' and INTTYPE = 'C' and POSITION > @p and FIELDNAME not like '.%'
      if @p is null break
      select @f = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and POSITION = @p
      select @d = @d + case when @d = '' then '' else ' or ' end + 's."' + @f + '" <> e."' + @f + '"'
      select @sql = 'select convert(varchar(290), ''#' + @t + '#'' + ' + @k + ' + ''#' + @f + '#S#'' + isnull(rtrim(s."' + @f + '"),'''')) k from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and s."' + @f + '" <> e."' + @f + '"'
       + ' union all select convert(varchar(290), ''#' + @t + '#'' + ' + @k + ' + ''#' + @f + '#E#'' + isnull(rtrim(e."' + @f + '"),'''')) k from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and s."' + @f + '" <> e."' + @f + '"'
      exec (@sql)
    end
    if @d = '' select @d = '1 = 0'
    select @sql = 'select ''#RESUMEN#' + @t + '#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock where s."' + @l + '" = ''S''))'
     + ' + ''#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock where s."' + @l + '" = ''S'' and not exists (select 1 from BAS.SAPSR3."' + @t + '" e noholdlock where e."' + @l + '" = ''E''' + @j + ')))'
     + ' + ''#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and (' + @d + ')))'
    exec (@sql)
  end
end
go
declare @t varchar(30), @l varchar(30), @p varchar(4), @f varchar(30), @j varchar(2000), @k varchar(2000), @d varchar(3000), @sql varchar(8000)
select @t = 'T8G30AT', @j = '', @k = '', @d = '', @p = '', @l = null
if object_id('BAS.SAPSR3.T8G30AT') is null
begin
  select '#T8G30AT#NO_ES_TABLA_TRANSPARENTE'
end
else
begin
  select @l = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG = 'X' and DATATYPE = 'LANG'
  if @l is null select '#T8G30AT#SIN_CAMPO_IDIOMA'
  else
  begin
    while 1 = 1
    begin
      select @p = min(POSITION) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG = 'X' and POSITION > @p and FIELDNAME not like '.%' and FIELDNAME <> @l
      if @p is null break
      select @f = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and POSITION = @p
      select @j = @j + ' and s."' + @f + '" = e."' + @f + '"'
      select @k = @k + case when @k = '' then '' else ' + ''|'' + ' end + 'isnull(rtrim(convert(varchar(100),s."' + @f + '")),'''')'
    end
    select @p = ''
    while 1 = 1
    begin
      select @p = min(POSITION) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG <> 'X' and INTTYPE = 'C' and POSITION > @p and FIELDNAME not like '.%'
      if @p is null break
      select @f = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and POSITION = @p
      select @d = @d + case when @d = '' then '' else ' or ' end + 's."' + @f + '" <> e."' + @f + '"'
      select @sql = 'select convert(varchar(290), ''#' + @t + '#'' + ' + @k + ' + ''#' + @f + '#S#'' + isnull(rtrim(s."' + @f + '"),'''')) k from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and s."' + @f + '" <> e."' + @f + '"'
       + ' union all select convert(varchar(290), ''#' + @t + '#'' + ' + @k + ' + ''#' + @f + '#E#'' + isnull(rtrim(e."' + @f + '"),'''')) k from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and s."' + @f + '" <> e."' + @f + '"'
      exec (@sql)
    end
    if @d = '' select @d = '1 = 0'
    select @sql = 'select ''#RESUMEN#' + @t + '#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock where s."' + @l + '" = ''S''))'
     + ' + ''#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock where s."' + @l + '" = ''S'' and not exists (select 1 from BAS.SAPSR3."' + @t + '" e noholdlock where e."' + @l + '" = ''E''' + @j + ')))'
     + ' + ''#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and (' + @d + ')))'
    exec (@sql)
  end
end
go
declare @t varchar(30), @l varchar(30), @p varchar(4), @f varchar(30), @j varchar(2000), @k varchar(2000), @d varchar(3000), @sql varchar(8000)
select @t = 'TABWT', @j = '', @k = '', @d = '', @p = '', @l = null
if object_id('BAS.SAPSR3.TABWT') is null
begin
  select '#TABWT#NO_ES_TABLA_TRANSPARENTE'
end
else
begin
  select @l = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG = 'X' and DATATYPE = 'LANG'
  if @l is null select '#TABWT#SIN_CAMPO_IDIOMA'
  else
  begin
    while 1 = 1
    begin
      select @p = min(POSITION) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG = 'X' and POSITION > @p and FIELDNAME not like '.%' and FIELDNAME <> @l
      if @p is null break
      select @f = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and POSITION = @p
      select @j = @j + ' and s."' + @f + '" = e."' + @f + '"'
      select @k = @k + case when @k = '' then '' else ' + ''|'' + ' end + 'isnull(rtrim(convert(varchar(100),s."' + @f + '")),'''')'
    end
    select @p = ''
    while 1 = 1
    begin
      select @p = min(POSITION) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG <> 'X' and INTTYPE = 'C' and POSITION > @p and FIELDNAME not like '.%'
      if @p is null break
      select @f = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and POSITION = @p
      select @d = @d + case when @d = '' then '' else ' or ' end + 's."' + @f + '" <> e."' + @f + '"'
      select @sql = 'select convert(varchar(290), ''#' + @t + '#'' + ' + @k + ' + ''#' + @f + '#S#'' + isnull(rtrim(s."' + @f + '"),'''')) k from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and s."' + @f + '" <> e."' + @f + '"'
       + ' union all select convert(varchar(290), ''#' + @t + '#'' + ' + @k + ' + ''#' + @f + '#E#'' + isnull(rtrim(e."' + @f + '"),'''')) k from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and s."' + @f + '" <> e."' + @f + '"'
      exec (@sql)
    end
    if @d = '' select @d = '1 = 0'
    select @sql = 'select ''#RESUMEN#' + @t + '#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock where s."' + @l + '" = ''S''))'
     + ' + ''#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock where s."' + @l + '" = ''S'' and not exists (select 1 from BAS.SAPSR3."' + @t + '" e noholdlock where e."' + @l + '" = ''E''' + @j + ')))'
     + ' + ''#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and (' + @d + ')))'
    exec (@sql)
  end
end
go
declare @t varchar(30), @l varchar(30), @p varchar(4), @f varchar(30), @j varchar(2000), @k varchar(2000), @d varchar(3000), @sql varchar(8000)
select @t = 'TAMLAY1T', @j = '', @k = '', @d = '', @p = '', @l = null
if object_id('BAS.SAPSR3.TAMLAY1T') is null
begin
  select '#TAMLAY1T#NO_ES_TABLA_TRANSPARENTE'
end
else
begin
  select @l = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG = 'X' and DATATYPE = 'LANG'
  if @l is null select '#TAMLAY1T#SIN_CAMPO_IDIOMA'
  else
  begin
    while 1 = 1
    begin
      select @p = min(POSITION) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG = 'X' and POSITION > @p and FIELDNAME not like '.%' and FIELDNAME <> @l
      if @p is null break
      select @f = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and POSITION = @p
      select @j = @j + ' and s."' + @f + '" = e."' + @f + '"'
      select @k = @k + case when @k = '' then '' else ' + ''|'' + ' end + 'isnull(rtrim(convert(varchar(100),s."' + @f + '")),'''')'
    end
    select @p = ''
    while 1 = 1
    begin
      select @p = min(POSITION) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG <> 'X' and INTTYPE = 'C' and POSITION > @p and FIELDNAME not like '.%'
      if @p is null break
      select @f = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and POSITION = @p
      select @d = @d + case when @d = '' then '' else ' or ' end + 's."' + @f + '" <> e."' + @f + '"'
      select @sql = 'select convert(varchar(290), ''#' + @t + '#'' + ' + @k + ' + ''#' + @f + '#S#'' + isnull(rtrim(s."' + @f + '"),'''')) k from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and s."' + @f + '" <> e."' + @f + '"'
       + ' union all select convert(varchar(290), ''#' + @t + '#'' + ' + @k + ' + ''#' + @f + '#E#'' + isnull(rtrim(e."' + @f + '"),'''')) k from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and s."' + @f + '" <> e."' + @f + '"'
      exec (@sql)
    end
    if @d = '' select @d = '1 = 0'
    select @sql = 'select ''#RESUMEN#' + @t + '#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock where s."' + @l + '" = ''S''))'
     + ' + ''#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock where s."' + @l + '" = ''S'' and not exists (select 1 from BAS.SAPSR3."' + @t + '" e noholdlock where e."' + @l + '" = ''E''' + @j + ')))'
     + ' + ''#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and (' + @d + ')))'
    exec (@sql)
  end
end
go
declare @t varchar(30), @l varchar(30), @p varchar(4), @f varchar(30), @j varchar(2000), @k varchar(2000), @d varchar(3000), @sql varchar(8000)
select @t = 'TAMLAYBT', @j = '', @k = '', @d = '', @p = '', @l = null
if object_id('BAS.SAPSR3.TAMLAYBT') is null
begin
  select '#TAMLAYBT#NO_ES_TABLA_TRANSPARENTE'
end
else
begin
  select @l = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG = 'X' and DATATYPE = 'LANG'
  if @l is null select '#TAMLAYBT#SIN_CAMPO_IDIOMA'
  else
  begin
    while 1 = 1
    begin
      select @p = min(POSITION) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG = 'X' and POSITION > @p and FIELDNAME not like '.%' and FIELDNAME <> @l
      if @p is null break
      select @f = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and POSITION = @p
      select @j = @j + ' and s."' + @f + '" = e."' + @f + '"'
      select @k = @k + case when @k = '' then '' else ' + ''|'' + ' end + 'isnull(rtrim(convert(varchar(100),s."' + @f + '")),'''')'
    end
    select @p = ''
    while 1 = 1
    begin
      select @p = min(POSITION) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG <> 'X' and INTTYPE = 'C' and POSITION > @p and FIELDNAME not like '.%'
      if @p is null break
      select @f = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and POSITION = @p
      select @d = @d + case when @d = '' then '' else ' or ' end + 's."' + @f + '" <> e."' + @f + '"'
      select @sql = 'select convert(varchar(290), ''#' + @t + '#'' + ' + @k + ' + ''#' + @f + '#S#'' + isnull(rtrim(s."' + @f + '"),'''')) k from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and s."' + @f + '" <> e."' + @f + '"'
       + ' union all select convert(varchar(290), ''#' + @t + '#'' + ' + @k + ' + ''#' + @f + '#E#'' + isnull(rtrim(e."' + @f + '"),'''')) k from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and s."' + @f + '" <> e."' + @f + '"'
      exec (@sql)
    end
    if @d = '' select @d = '1 = 0'
    select @sql = 'select ''#RESUMEN#' + @t + '#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock where s."' + @l + '" = ''S''))'
     + ' + ''#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock where s."' + @l + '" = ''S'' and not exists (select 1 from BAS.SAPSR3."' + @t + '" e noholdlock where e."' + @l + '" = ''E''' + @j + ')))'
     + ' + ''#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and (' + @d + ')))'
    exec (@sql)
  end
end
go
declare @t varchar(30), @l varchar(30), @p varchar(4), @f varchar(30), @j varchar(2000), @k varchar(2000), @d varchar(3000), @sql varchar(8000)
select @t = 'TCURT', @j = '', @k = '', @d = '', @p = '', @l = null
if object_id('BAS.SAPSR3.TCURT') is null
begin
  select '#TCURT#NO_ES_TABLA_TRANSPARENTE'
end
else
begin
  select @l = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG = 'X' and DATATYPE = 'LANG'
  if @l is null select '#TCURT#SIN_CAMPO_IDIOMA'
  else
  begin
    while 1 = 1
    begin
      select @p = min(POSITION) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG = 'X' and POSITION > @p and FIELDNAME not like '.%' and FIELDNAME <> @l
      if @p is null break
      select @f = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and POSITION = @p
      select @j = @j + ' and s."' + @f + '" = e."' + @f + '"'
      select @k = @k + case when @k = '' then '' else ' + ''|'' + ' end + 'isnull(rtrim(convert(varchar(100),s."' + @f + '")),'''')'
    end
    select @p = ''
    while 1 = 1
    begin
      select @p = min(POSITION) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG <> 'X' and INTTYPE = 'C' and POSITION > @p and FIELDNAME not like '.%'
      if @p is null break
      select @f = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and POSITION = @p
      select @d = @d + case when @d = '' then '' else ' or ' end + 's."' + @f + '" <> e."' + @f + '"'
      select @sql = 'select convert(varchar(290), ''#' + @t + '#'' + ' + @k + ' + ''#' + @f + '#S#'' + isnull(rtrim(s."' + @f + '"),'''')) k from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and s."' + @f + '" <> e."' + @f + '"'
       + ' union all select convert(varchar(290), ''#' + @t + '#'' + ' + @k + ' + ''#' + @f + '#E#'' + isnull(rtrim(e."' + @f + '"),'''')) k from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and s."' + @f + '" <> e."' + @f + '"'
      exec (@sql)
    end
    if @d = '' select @d = '1 = 0'
    select @sql = 'select ''#RESUMEN#' + @t + '#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock where s."' + @l + '" = ''S''))'
     + ' + ''#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock where s."' + @l + '" = ''S'' and not exists (select 1 from BAS.SAPSR3."' + @t + '" e noholdlock where e."' + @l + '" = ''E''' + @j + ')))'
     + ' + ''#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and (' + @d + ')))'
    exec (@sql)
  end
end
go
declare @t varchar(30), @l varchar(30), @p varchar(4), @f varchar(30), @j varchar(2000), @k varchar(2000), @d varchar(3000), @sql varchar(8000)
select @t = 'TTYPT', @j = '', @k = '', @d = '', @p = '', @l = null
if object_id('BAS.SAPSR3.TTYPT') is null
begin
  select '#TTYPT#NO_ES_TABLA_TRANSPARENTE'
end
else
begin
  select @l = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG = 'X' and DATATYPE = 'LANG'
  if @l is null select '#TTYPT#SIN_CAMPO_IDIOMA'
  else
  begin
    while 1 = 1
    begin
      select @p = min(POSITION) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG = 'X' and POSITION > @p and FIELDNAME not like '.%' and FIELDNAME <> @l
      if @p is null break
      select @f = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and POSITION = @p
      select @j = @j + ' and s."' + @f + '" = e."' + @f + '"'
      select @k = @k + case when @k = '' then '' else ' + ''|'' + ' end + 'isnull(rtrim(convert(varchar(100),s."' + @f + '")),'''')'
    end
    select @p = ''
    while 1 = 1
    begin
      select @p = min(POSITION) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG <> 'X' and INTTYPE = 'C' and POSITION > @p and FIELDNAME not like '.%'
      if @p is null break
      select @f = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and POSITION = @p
      select @d = @d + case when @d = '' then '' else ' or ' end + 's."' + @f + '" <> e."' + @f + '"'
      select @sql = 'select convert(varchar(290), ''#' + @t + '#'' + ' + @k + ' + ''#' + @f + '#S#'' + isnull(rtrim(s."' + @f + '"),'''')) k from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and s."' + @f + '" <> e."' + @f + '"'
       + ' union all select convert(varchar(290), ''#' + @t + '#'' + ' + @k + ' + ''#' + @f + '#E#'' + isnull(rtrim(e."' + @f + '"),'''')) k from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and s."' + @f + '" <> e."' + @f + '"'
      exec (@sql)
    end
    if @d = '' select @d = '1 = 0'
    select @sql = 'select ''#RESUMEN#' + @t + '#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock where s."' + @l + '" = ''S''))'
     + ' + ''#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock where s."' + @l + '" = ''S'' and not exists (select 1 from BAS.SAPSR3."' + @t + '" e noholdlock where e."' + @l + '" = ''E''' + @j + ')))'
     + ' + ''#'' + convert(varchar(12),(select count(*) from BAS.SAPSR3."' + @t + '" s noholdlock, BAS.SAPSR3."' + @t + '" e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and (' + @d + ')))'
    exec (@sql)
  end
end
go
select 'fin', getdate()
go
