/* 7_lista_s_vs_e.sql - SOLO LECTURA. Lista TODAS las claves S distintas de E
   (una por linea: tabla|clave|campos que difieren) para cruzarlas offline con
   las dos carpetas de lotes de reversion. Correr: correr_sql.bat sql\07_lista_s_vs_e.sql */
set nocount on
go
set quoted_identifier on
go
select 'inicio', getdate()
go
select convert(varchar(290), '#T100#' + rtrim(s."ARBGB") + '|' + rtrim(s."MSGNR") + '#' + '') k
from BAS.SAPSR3."T100" s noholdlock, BAS.SAPSR3."T100" e noholdlock
where s."SPRSL" = 'S' and e."SPRSL" = 'E' and s."ARBGB" = e."ARBGB" and s."MSGNR" = e."MSGNR" and (s."TEXT" <> e."TEXT")
go
select convert(varchar(290), '#TSTCT#' + rtrim(s."TCODE") + '#' + '') k
from BAS.SAPSR3."TSTCT" s noholdlock, BAS.SAPSR3."TSTCT" e noholdlock
where s."SPRSL" = 'S' and e."SPRSL" = 'E' and s."TCODE" = e."TCODE" and (s."TTEXT" <> e."TTEXT")
go
select convert(varchar(290), '#DD01T#' + rtrim(s."DOMNAME") + '|' + rtrim(s."AS4LOCAL") + '|' + rtrim(s."AS4VERS") + '#' + '') k
from BAS.SAPSR3."DD01T" s noholdlock, BAS.SAPSR3."DD01T" e noholdlock
where s."DDLANGUAGE" = 'S' and e."DDLANGUAGE" = 'E' and s."DOMNAME" = e."DOMNAME" and s."AS4LOCAL" = e."AS4LOCAL" and s."AS4VERS" = e."AS4VERS" and (s."DDTEXT" <> e."DDTEXT")
go
select convert(varchar(290), '#DD02T#' + rtrim(s."TABNAME") + '|' + rtrim(s."AS4LOCAL") + '|' + rtrim(s."AS4VERS") + '#' + '') k
from BAS.SAPSR3."DD02T" s noholdlock, BAS.SAPSR3."DD02T" e noholdlock
where s."DDLANGUAGE" = 'S' and e."DDLANGUAGE" = 'E' and s."TABNAME" = e."TABNAME" and s."AS4LOCAL" = e."AS4LOCAL" and s."AS4VERS" = e."AS4VERS" and (s."DDTEXT" <> e."DDTEXT")
go
select convert(varchar(290), '#DD04T#' + rtrim(s."ROLLNAME") + '|' + rtrim(s."AS4LOCAL") + '|' + rtrim(s."AS4VERS") + '#' + case when s."DDTEXT" <> e."DDTEXT" then 'DDTEXT,' else '' end + case when s."REPTEXT" <> e."REPTEXT" then 'REPTEXT,' else '' end + case when s."SCRTEXT_S" <> e."SCRTEXT_S" then 'SCRTEXT_S,' else '' end + case when s."SCRTEXT_M" <> e."SCRTEXT_M" then 'SCRTEXT_M,' else '' end + case when s."SCRTEXT_L" <> e."SCRTEXT_L" then 'SCRTEXT_L,' else '' end) k
from BAS.SAPSR3."DD04T" s noholdlock, BAS.SAPSR3."DD04T" e noholdlock
where s."DDLANGUAGE" = 'S' and e."DDLANGUAGE" = 'E' and s."ROLLNAME" = e."ROLLNAME" and s."AS4LOCAL" = e."AS4LOCAL" and s."AS4VERS" = e."AS4VERS" and (s."DDTEXT" <> e."DDTEXT" or s."REPTEXT" <> e."REPTEXT" or s."SCRTEXT_S" <> e."SCRTEXT_S" or s."SCRTEXT_M" <> e."SCRTEXT_M" or s."SCRTEXT_L" <> e."SCRTEXT_L")
go
select convert(varchar(290), '#DD07T#' + rtrim(s."DOMNAME") + '|' + rtrim(s."AS4LOCAL") + '|' + rtrim(s."VALPOS") + '|' + rtrim(s."AS4VERS") + '#' + '') k
from BAS.SAPSR3."DD07T" s noholdlock, BAS.SAPSR3."DD07T" e noholdlock
where s."DDLANGUAGE" = 'S' and e."DDLANGUAGE" = 'E' and s."DOMNAME" = e."DOMNAME" and s."AS4LOCAL" = e."AS4LOCAL" and s."VALPOS" = e."VALPOS" and s."AS4VERS" = e."AS4VERS" and (s."DDTEXT" <> e."DDTEXT")
go
select convert(varchar(290), '#DD30T#' + rtrim(s."SHLPNAME") + '|' + rtrim(s."AS4LOCAL") + '#' + '') k
from BAS.SAPSR3."DD30T" s noholdlock, BAS.SAPSR3."DD30T" e noholdlock
where s."DDLANGUAGE" = 'S' and e."DDLANGUAGE" = 'E' and s."SHLPNAME" = e."SHLPNAME" and s."AS4LOCAL" = e."AS4LOCAL" and (s."DDTEXT" <> e."DDTEXT")
go
select convert(varchar(290), '#D020T#' + rtrim(s."PROG") + '|' + rtrim(s."DYNR") + '#' + '') k
from BAS.SAPSR3."D020T" s noholdlock, BAS.SAPSR3."D020T" e noholdlock
where s."LANG" = 'S' and e."LANG" = 'E' and s."PROG" = e."PROG" and s."DYNR" = e."DYNR" and (s."DTXT" <> e."DTXT")
go
select convert(varchar(290), '#D021T#' + rtrim(s."PROG") + '|' + rtrim(s."DYNR") + '|' + rtrim(s."FLDN") + '#' + '') k
from BAS.SAPSR3."D021T" s noholdlock, BAS.SAPSR3."D021T" e noholdlock
where s."LANG" = 'S' and e."LANG" = 'E' and s."PROG" = e."PROG" and s."DYNR" = e."DYNR" and s."FLDN" = e."FLDN" and (s."DTXT" <> e."DTXT")
go
select convert(varchar(290), '#RSMPTEXTS#' + rtrim(s."PROGNAME") + '|' + rtrim(s."OBJ_TYPE") + '|' + rtrim(s."OBJ_CODE") + '|' + rtrim(s."SUB_CODE") + '|' + rtrim(s."TEXTTYPE") + '#' + '') k
from BAS.SAPSR3."RSMPTEXTS" s noholdlock, BAS.SAPSR3."RSMPTEXTS" e noholdlock
where s."SPRSL" = 'S' and e."SPRSL" = 'E' and s."PROGNAME" = e."PROGNAME" and s."OBJ_TYPE" = e."OBJ_TYPE" and s."OBJ_CODE" = e."OBJ_CODE" and s."SUB_CODE" = e."SUB_CODE" and s."TEXTTYPE" = e."TEXTTYPE" and (s."TEXT" <> e."TEXT")
go
select convert(varchar(290), '#CUS_IMGACT#' + rtrim(s."ACTIVITY") + '#' + '') k
from BAS.SAPSR3."CUS_IMGACT" s noholdlock, BAS.SAPSR3."CUS_IMGACT" e noholdlock
where s."SPRAS" = 'S' and e."SPRAS" = 'E' and s."ACTIVITY" = e."ACTIVITY" and (s."TEXT" <> e."TEXT")
go
select 'fin', getdate()
go
