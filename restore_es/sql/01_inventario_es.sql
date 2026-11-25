/* ======================================================================
   1_inventario_es.sql - Inventario del español (idioma S). SOLO LECTURA.
   Por cada tabla tocada por el proyecto cuenta filas por idioma en BAS
   (hoy) y en BAS_OLD (dump del 18/11): S, E, D y el resto.
   No usa datalength() ni lee columnas IMAGE/TEXT.
   Tablas de trabajo chicas en tempdb (zi_tab, zi_res), se borran al final.
   Correr con:  correr_sql.bat sql\01_inventario_es.sql
   ====================================================================== */
set nocount on
go
set quoted_identifier on
go
select 'inicio' as paso, getdate()
go
if object_id('tempdb..zi_tab') is not null drop table tempdb..zi_tab
go
if object_id('tempdb..zi_res') is not null drop table tempdb..zi_res
go
create table tempdb..zi_tab (tab varchar(30) not null)
go
create table tempdb..zi_res (tab varchar(30) not null, base varchar(10) not null, lcol varchar(30) null,
  s int null, e int null, d int null, otros int null, nota varchar(60) null)
go
insert tempdb..zi_tab values ('ANKT')
insert tempdb..zi_tab values ('D021T')
insert tempdb..zi_tab values ('DD01T')
insert tempdb..zi_tab values ('DD02T')
insert tempdb..zi_tab values ('DD07T')
insert tempdb..zi_tab values ('DD30T')
insert tempdb..zi_tab values ('RSMPTEXTS')
insert tempdb..zi_tab values ('SETCLST')
insert tempdb..zi_tab values ('SETEXITST')
insert tempdb..zi_tab values ('SETHEADERT')
insert tempdb..zi_tab values ('SETLINET')
insert tempdb..zi_tab values ('T003T')
insert tempdb..zi_tab values ('T004G')
insert tempdb..zi_tab values ('T005T')
insert tempdb..zi_tab values ('T006T')
insert tempdb..zi_tab values ('T011T')
insert tempdb..zi_tab values ('T014T')
insert tempdb..zi_tab values ('T015VT')
insert tempdb..zi_tab values ('T015W1T')
insert tempdb..zi_tab values ('T015WT')
insert tempdb..zi_tab values ('T015XT')
insert tempdb..zi_tab values ('T021STDT')
insert tempdb..zi_tab values ('T022T')
insert tempdb..zi_tab values ('T023T')
insert tempdb..zi_tab values ('T025T')
insert tempdb..zi_tab values ('T026T')
insert tempdb..zi_tab values ('T035T')
insert tempdb..zi_tab values ('T036T')
insert tempdb..zi_tab values ('T039T')
insert tempdb..zi_tab values ('T041CT')
insert tempdb..zi_tab values ('T042ZDT')
insert tempdb..zi_tab values ('T043ST')
insert tempdb..zi_tab values ('T053S')
insert tempdb..zi_tab values ('T058T')
insert tempdb..zi_tab values ('T059U')
insert tempdb..zi_tab values ('T059ZT')
insert tempdb..zi_tab values ('T082AVIEW0T')
insert tempdb..zi_tab values ('T082T')
insert tempdb..zi_tab values ('T090NAT')
insert tempdb..zi_tab values ('T090NRT')
insert tempdb..zi_tab values ('T090S')
insert tempdb..zi_tab values ('T090T')
insert tempdb..zi_tab values ('T090U')
insert tempdb..zi_tab values ('T091S')
insert tempdb..zi_tab values ('T091T')
insert tempdb..zi_tab values ('T093T')
insert tempdb..zi_tab values ('T093_ACCOBJT')
insert tempdb..zi_tab values ('T094S')
insert tempdb..zi_tab values ('T095T')
insert tempdb..zi_tab values ('T096T')
insert tempdb..zi_tab values ('T100')
insert tempdb..zi_tab values ('T800T')
insert tempdb..zi_tab values ('T802T')
insert tempdb..zi_tab values ('T803T')
insert tempdb..zi_tab values ('T804BT')
insert tempdb..zi_tab values ('T804T')
insert tempdb..zi_tab values ('T807T')
insert tempdb..zi_tab values ('T80DT')
insert tempdb..zi_tab values ('T80IT')
insert tempdb..zi_tab values ('T856T')
insert tempdb..zi_tab values ('T857T')
insert tempdb..zi_tab values ('T858T')
insert tempdb..zi_tab values ('T881T')
insert tempdb..zi_tab values ('T888T')
insert tempdb..zi_tab values ('T894T')
insert tempdb..zi_tab values ('T8G01T')
insert tempdb..zi_tab values ('T8G02T')
insert tempdb..zi_tab values ('T8G031T')
insert tempdb..zi_tab values ('T8G03T')
insert tempdb..zi_tab values ('T8G30AT')
insert tempdb..zi_tab values ('TABWT')
insert tempdb..zi_tab values ('TAMLAY1T')
insert tempdb..zi_tab values ('TAMLAYBT')
insert tempdb..zi_tab values ('TCURT')
insert tempdb..zi_tab values ('TSTCT')
insert tempdb..zi_tab values ('TTYPT')
insert tempdb..zi_tab values ('CUS_IMGACT')
insert tempdb..zi_tab values ('TNODEIMGT')
insert tempdb..zi_tab values ('DD04T')
insert tempdb..zi_tab values ('D020T')
insert tempdb..zi_tab values ('REPOTEXT')
insert tempdb..zi_tab values ('DOKHL')
insert tempdb..zi_tab values ('DOKIL')
insert tempdb..zi_tab values ('DOKCLU')
insert tempdb..zi_tab values ('DDFTX')
go
declare @t varchar(30), @b varchar(10), @uid int, @id int, @l varchar(30), @sql varchar(4000)
select @t = min(tab) from tempdb..zi_tab
while @t is not null
begin
  select @b = 'BAS'
  while @b is not null
  begin
    select @uid = null, @id = null, @l = null
    if @b = 'BAS'
    begin
      select @uid = uid from BAS..sysusers where name = 'SAPSR3'
      select @id = id from BAS..sysobjects where name = @t and uid = @uid and type = 'U'
      if @id is not null
        select @l = min(name) from BAS..syscolumns where id = @id and name in ('DDLANGUAGE','SPRSL','SPRAS','LANGU','LANGUAGE','LANG','SPRACHE')
    end
    else
    begin
      select @uid = uid from BAS_OLD..sysusers where name = 'SAPSR3'
      select @id = id from BAS_OLD..sysobjects where name = @t and uid = @uid and type = 'U'
      if @id is not null
        select @l = min(name) from BAS_OLD..syscolumns where id = @id and name in ('DDLANGUAGE','SPRSL','SPRAS','LANGU','LANGUAGE','LANG','SPRACHE')
    end
    if @id is null
      insert tempdb..zi_res (tab, base, nota) values (@t, @b, 'no existe (tabla pool/cluster o sin tabla fisica)')
    else if @l is null
      insert tempdb..zi_res (tab, base, nota) values (@t, @b, 'sin columna de idioma conocida')
    else
    begin
      select @sql = 'insert tempdb..zi_res (tab, base, lcol, s, e, d, otros) select ''' + @t + ''', ''' + @b + ''', ''' + @l + ''', '
        + 'sum(case when "' + @l + '" = ''S'' then 1 else 0 end), '
        + 'sum(case when "' + @l + '" = ''E'' then 1 else 0 end), '
        + 'sum(case when "' + @l + '" = ''D'' then 1 else 0 end), '
        + 'sum(case when "' + @l + '" not in (''S'',''E'',''D'') then 1 else 0 end) '
        + 'from ' + @b + '.SAPSR3."' + @t + '" noholdlock'
      exec (@sql)
    end
    select @b = case when @b = 'BAS' then 'BAS_OLD' else null end
  end
  select @t = min(tab) from tempdb..zi_tab where tab > @t
end
go
print '=== Filas por idioma (BAS = hoy, BAS_OLD = dump 18/11) ==='
select tab, base, lcol, s, e, d, otros, nota from tempdb..zi_res order by tab, base
go
print '=== Totales S ==='
select base, sum(s) as filas_s, count(*) as tablas from tempdb..zi_res group by base
go
print '=== Usuarios con idioma de logon S (USR01), todos los mandantes ==='
select MANDT, BNAME from BAS.SAPSR3.USR01 noholdlock where LANGU = 'S' order by MANDT, BNAME
go
print '=== Idiomas instalados segun T002/TCP0? (T002C: idiomas clasificados) ==='
select * from BAS.SAPSR3.T002C noholdlock where SPRAS in ('S','E','D')
go
drop table tempdb..zi_tab
go
drop table tempdb..zi_res
go
select 'fin' as paso, getdate()
go
