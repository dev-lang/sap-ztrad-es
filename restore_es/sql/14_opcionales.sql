/* 14_opcionales.sql - SOLO LECTURA.
   1) MENUJ4G2 en RSMPTEXTS: filas S y E (menu que quedo manual en SE41/SE63).
   2) DDFTX (textos de campos generados desde DD04T): filas S, S sin E, S distinto de E
      por campo de texto, y 20 ejemplos.
   Correr: correr_sql.bat sql\14_opcionales.sql */
set nocount on
go
set quoted_identifier on
go
select 'inicio', getdate()
go
print '=== 1) MENUJ4G2: filas por idioma ==='
select SPRSL, count(*) filas from BAS.SAPSR3.RSMPTEXTS noholdlock where PROGNAME = 'MENUJ4G2' group by SPRSL order by SPRSL
go
print '=== 1) MENUJ4G2: filas S distintas de E (o sin E) ==='
select s.OBJ_TYPE, s.OBJ_CODE, s.SUB_CODE, s.TEXTTYPE, s.TEXT texto_s, e.TEXT texto_e
from BAS.SAPSR3.RSMPTEXTS s noholdlock, BAS.SAPSR3.RSMPTEXTS e noholdlock
where s.PROGNAME = 'MENUJ4G2' and s.SPRSL = 'S' and e.PROGNAME =* s.PROGNAME and e.SPRSL = 'E'
  and e.OBJ_TYPE =* s.OBJ_TYPE and e.OBJ_CODE =* s.OBJ_CODE and e.SUB_CODE =* s.SUB_CODE and e.TEXTTYPE =* s.TEXTTYPE
  and (e.TEXT is null or s.TEXT <> e.TEXT)
go
print '=== 2) DDFTX: columnas ==='
select FIELDNAME, KEYFLAG, DATATYPE, LENG from BAS.SAPSR3.DD03L noholdlock where TABNAME = 'DDFTX' and AS4LOCAL = 'A' order by POSITION
go
print '=== 2) DDFTX: resumen y diferencias por campo ==='
declare @t varchar(30), @l varchar(30), @p varchar(4), @f varchar(30), @j varchar(2000), @sql varchar(8000)
select @t = 'DDFTX', @j = '', @p = ''
select @l = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG = 'X' and DATATYPE = 'LANG'
while 1 = 1
begin
  select @p = min(POSITION) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG = 'X' and POSITION > @p and FIELDNAME not like '.%' and FIELDNAME <> @l
  if @p is null break
  select @f = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and POSITION = @p
  select @j = @j + ' and s."' + @f + '" = e."' + @f + '"'
end
select @sql = 'select ''S'' idioma, count(*) filas from BAS.SAPSR3.DDFTX noholdlock where "' + @l + '" = ''S'''
 + ' union all select ''E'', count(*) from BAS.SAPSR3.DDFTX noholdlock where "' + @l + '" = ''E'''
 + ' union all select ''S sin E'', count(*) from BAS.SAPSR3.DDFTX s noholdlock where s."' + @l + '" = ''S'' and not exists (select 1 from BAS.SAPSR3.DDFTX e noholdlock where e."' + @l + '" = ''E''' + @j + ')'
exec (@sql)
select @p = ''
while 1 = 1
begin
  select @p = min(POSITION) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and KEYFLAG <> 'X' and INTTYPE = 'C' and POSITION > @p and FIELDNAME not like '.%'
  if @p is null break
  select @f = min(FIELDNAME) from BAS.SAPSR3.DD03L noholdlock where TABNAME = @t and AS4LOCAL = 'A' and POSITION = @p
  select @sql = 'select ''' + @f + ''' campo, count(*) s_distinto_e from BAS.SAPSR3.DDFTX s noholdlock, BAS.SAPSR3.DDFTX e noholdlock where s."' + @l + '" = ''S'' and e."' + @l + '" = ''E''' + @j + ' and s."' + @f + '" <> e."' + @f + '"'
  exec (@sql)
end
go
print '=== 2) DDFTX: 20 ejemplos S distinto de E (FIELDTEXT/SCRTEXT_L) ==='
set rowcount 20
go
select s.TABNAME, s.FIELDNAME, s.FIELDTEXT texto_s, e.FIELDTEXT texto_e, s.SCRTEXT_L scr_s, e.SCRTEXT_L scr_e
from BAS.SAPSR3.DDFTX s noholdlock, BAS.SAPSR3.DDFTX e noholdlock
where s.DDLANGUAGE = 'S' and e.DDLANGUAGE = 'E' and s.TABNAME = e.TABNAME and s.FIELDNAME = e.FIELDNAME
  and (s.FIELDTEXT <> e.FIELDTEXT or s.SCRTEXT_L <> e.SCRTEXT_L)
go
set rowcount 0
go
select 'fin', getdate()
go
