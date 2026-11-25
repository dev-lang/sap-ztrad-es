/* 6_detalle_s_vs_e.sql - SOLO LECTURA. Clasifica las filas S distintas de E:
   ml_s = objeto con idioma original espanol (TADIR MASTERLANG='S'), resto = otro.
   Muestra hasta 15 ejemplos del resto por tabla.  Correr: correr_sql.bat sql\06_detalle_s_vs_e.sql */
set nocount on
go
set quoted_identifier on
go
select 'inicio', getdate()
go
select 'T100' tab, (select count(*) from BAS.SAPSR3."T100" s noholdlock, BAS.SAPSR3."T100" e noholdlock where s."SPRSL" = 'S' and e."SPRSL" = 'E' and s."ARBGB" = e."ARBGB" and s."MSGNR" = e."MSGNR" and (s."TEXT" <> e."TEXT")) s_distinto_e, (select count(*) from BAS.SAPSR3."T100" s noholdlock, BAS.SAPSR3."T100" e noholdlock where s."SPRSL" = 'S' and e."SPRSL" = 'E' and s."ARBGB" = e."ARBGB" and s."MSGNR" = e."MSGNR" and (s."TEXT" <> e."TEXT") and exists (select 1 from BAS.SAPSR3.TADIR a noholdlock where a.PGMID='R3TR' and a.OBJECT='MSAG' and a.OBJ_NAME=s."ARBGB" and a.MASTERLANG='S')) ml_s
go
set rowcount 15
go
select 'T100' tab, s."ARBGB", s."MSGNR", s."TEXT" texto_s, e."TEXT" texto_e from BAS.SAPSR3."T100" s noholdlock, BAS.SAPSR3."T100" e noholdlock where s."SPRSL" = 'S' and e."SPRSL" = 'E' and s."ARBGB" = e."ARBGB" and s."MSGNR" = e."MSGNR" and (s."TEXT" <> e."TEXT") and not exists (select 1 from BAS.SAPSR3.TADIR a noholdlock where a.PGMID='R3TR' and a.MASTERLANG='S' and a.OBJ_NAME=s."ARBGB" )
go
set rowcount 0
go
select 'TSTCT' tab, (select count(*) from BAS.SAPSR3."TSTCT" s noholdlock, BAS.SAPSR3."TSTCT" e noholdlock where s."SPRSL" = 'S' and e."SPRSL" = 'E' and s."TCODE" = e."TCODE" and (s."TTEXT" <> e."TTEXT")) s_distinto_e, (select count(*) from BAS.SAPSR3."TSTCT" s noholdlock, BAS.SAPSR3."TSTCT" e noholdlock where s."SPRSL" = 'S' and e."SPRSL" = 'E' and s."TCODE" = e."TCODE" and (s."TTEXT" <> e."TTEXT") and exists (select 1 from BAS.SAPSR3.TADIR a noholdlock where a.PGMID='R3TR' and a.OBJECT='TRAN' and a.OBJ_NAME=s."TCODE" and a.MASTERLANG='S')) ml_s
go
set rowcount 15
go
select 'TSTCT' tab, s."TCODE", s."TTEXT" texto_s, e."TTEXT" texto_e from BAS.SAPSR3."TSTCT" s noholdlock, BAS.SAPSR3."TSTCT" e noholdlock where s."SPRSL" = 'S' and e."SPRSL" = 'E' and s."TCODE" = e."TCODE" and (s."TTEXT" <> e."TTEXT") and not exists (select 1 from BAS.SAPSR3.TADIR a noholdlock where a.PGMID='R3TR' and a.MASTERLANG='S' and a.OBJ_NAME=s."TCODE" )
go
set rowcount 0
go
select 'DD01T' tab, (select count(*) from BAS.SAPSR3."DD01T" s noholdlock, BAS.SAPSR3."DD01T" e noholdlock where s."DDLANGUAGE" = 'S' and e."DDLANGUAGE" = 'E' and s."DOMNAME" = e."DOMNAME" and s."AS4LOCAL" = e."AS4LOCAL" and s."AS4VERS" = e."AS4VERS" and (s."DDTEXT" <> e."DDTEXT")) s_distinto_e, (select count(*) from BAS.SAPSR3."DD01T" s noholdlock, BAS.SAPSR3."DD01T" e noholdlock where s."DDLANGUAGE" = 'S' and e."DDLANGUAGE" = 'E' and s."DOMNAME" = e."DOMNAME" and s."AS4LOCAL" = e."AS4LOCAL" and s."AS4VERS" = e."AS4VERS" and (s."DDTEXT" <> e."DDTEXT") and exists (select 1 from BAS.SAPSR3.TADIR a noholdlock where a.PGMID='R3TR' and a.OBJECT='DOMA' and a.OBJ_NAME=s."DOMNAME" and a.MASTERLANG='S')) ml_s
go
set rowcount 15
go
select 'DD01T' tab, s."DOMNAME", s."AS4LOCAL", s."DDTEXT" texto_s, e."DDTEXT" texto_e from BAS.SAPSR3."DD01T" s noholdlock, BAS.SAPSR3."DD01T" e noholdlock where s."DDLANGUAGE" = 'S' and e."DDLANGUAGE" = 'E' and s."DOMNAME" = e."DOMNAME" and s."AS4LOCAL" = e."AS4LOCAL" and s."AS4VERS" = e."AS4VERS" and (s."DDTEXT" <> e."DDTEXT") and not exists (select 1 from BAS.SAPSR3.TADIR a noholdlock where a.PGMID='R3TR' and a.MASTERLANG='S' and a.OBJ_NAME=s."DOMNAME" )
go
set rowcount 0
go
select 'DD02T' tab, (select count(*) from BAS.SAPSR3."DD02T" s noholdlock, BAS.SAPSR3."DD02T" e noholdlock where s."DDLANGUAGE" = 'S' and e."DDLANGUAGE" = 'E' and s."TABNAME" = e."TABNAME" and s."AS4LOCAL" = e."AS4LOCAL" and s."AS4VERS" = e."AS4VERS" and (s."DDTEXT" <> e."DDTEXT")) s_distinto_e, (select count(*) from BAS.SAPSR3."DD02T" s noholdlock, BAS.SAPSR3."DD02T" e noholdlock where s."DDLANGUAGE" = 'S' and e."DDLANGUAGE" = 'E' and s."TABNAME" = e."TABNAME" and s."AS4LOCAL" = e."AS4LOCAL" and s."AS4VERS" = e."AS4VERS" and (s."DDTEXT" <> e."DDTEXT") and exists (select 1 from BAS.SAPSR3.TADIR a noholdlock where a.PGMID='R3TR' and a.OBJECT='TABL' and a.OBJ_NAME=s."TABNAME" and a.MASTERLANG='S')) ml_s
go
set rowcount 15
go
select 'DD02T' tab, s."TABNAME", s."AS4LOCAL", s."DDTEXT" texto_s, e."DDTEXT" texto_e from BAS.SAPSR3."DD02T" s noholdlock, BAS.SAPSR3."DD02T" e noholdlock where s."DDLANGUAGE" = 'S' and e."DDLANGUAGE" = 'E' and s."TABNAME" = e."TABNAME" and s."AS4LOCAL" = e."AS4LOCAL" and s."AS4VERS" = e."AS4VERS" and (s."DDTEXT" <> e."DDTEXT") and not exists (select 1 from BAS.SAPSR3.TADIR a noholdlock where a.PGMID='R3TR' and a.MASTERLANG='S' and a.OBJ_NAME=s."TABNAME" )
go
set rowcount 0
go
select 'DD04T' tab, (select count(*) from BAS.SAPSR3."DD04T" s noholdlock, BAS.SAPSR3."DD04T" e noholdlock where s."DDLANGUAGE" = 'S' and e."DDLANGUAGE" = 'E' and s."ROLLNAME" = e."ROLLNAME" and s."AS4LOCAL" = e."AS4LOCAL" and s."AS4VERS" = e."AS4VERS" and (s."DDTEXT" <> e."DDTEXT" or s."REPTEXT" <> e."REPTEXT" or s."SCRTEXT_S" <> e."SCRTEXT_S" or s."SCRTEXT_M" <> e."SCRTEXT_M" or s."SCRTEXT_L" <> e."SCRTEXT_L")) s_distinto_e, (select count(*) from BAS.SAPSR3."DD04T" s noholdlock, BAS.SAPSR3."DD04T" e noholdlock where s."DDLANGUAGE" = 'S' and e."DDLANGUAGE" = 'E' and s."ROLLNAME" = e."ROLLNAME" and s."AS4LOCAL" = e."AS4LOCAL" and s."AS4VERS" = e."AS4VERS" and (s."DDTEXT" <> e."DDTEXT" or s."REPTEXT" <> e."REPTEXT" or s."SCRTEXT_S" <> e."SCRTEXT_S" or s."SCRTEXT_M" <> e."SCRTEXT_M" or s."SCRTEXT_L" <> e."SCRTEXT_L") and exists (select 1 from BAS.SAPSR3.TADIR a noholdlock where a.PGMID='R3TR' and a.OBJECT='DTEL' and a.OBJ_NAME=s."ROLLNAME" and a.MASTERLANG='S')) ml_s
go
set rowcount 15
go
select 'DD04T' tab, s."ROLLNAME", s."AS4LOCAL", s."SCRTEXT_L" texto_s, e."SCRTEXT_L" texto_e from BAS.SAPSR3."DD04T" s noholdlock, BAS.SAPSR3."DD04T" e noholdlock where s."DDLANGUAGE" = 'S' and e."DDLANGUAGE" = 'E' and s."ROLLNAME" = e."ROLLNAME" and s."AS4LOCAL" = e."AS4LOCAL" and s."AS4VERS" = e."AS4VERS" and (s."DDTEXT" <> e."DDTEXT" or s."REPTEXT" <> e."REPTEXT" or s."SCRTEXT_S" <> e."SCRTEXT_S" or s."SCRTEXT_M" <> e."SCRTEXT_M" or s."SCRTEXT_L" <> e."SCRTEXT_L") and not exists (select 1 from BAS.SAPSR3.TADIR a noholdlock where a.PGMID='R3TR' and a.MASTERLANG='S' and a.OBJ_NAME=s."ROLLNAME" )
go
set rowcount 0
go
select 'DD07T' tab, (select count(*) from BAS.SAPSR3."DD07T" s noholdlock, BAS.SAPSR3."DD07T" e noholdlock where s."DDLANGUAGE" = 'S' and e."DDLANGUAGE" = 'E' and s."DOMNAME" = e."DOMNAME" and s."AS4LOCAL" = e."AS4LOCAL" and s."VALPOS" = e."VALPOS" and s."AS4VERS" = e."AS4VERS" and (s."DDTEXT" <> e."DDTEXT")) s_distinto_e, (select count(*) from BAS.SAPSR3."DD07T" s noholdlock, BAS.SAPSR3."DD07T" e noholdlock where s."DDLANGUAGE" = 'S' and e."DDLANGUAGE" = 'E' and s."DOMNAME" = e."DOMNAME" and s."AS4LOCAL" = e."AS4LOCAL" and s."VALPOS" = e."VALPOS" and s."AS4VERS" = e."AS4VERS" and (s."DDTEXT" <> e."DDTEXT") and exists (select 1 from BAS.SAPSR3.TADIR a noholdlock where a.PGMID='R3TR' and a.OBJECT='DOMA' and a.OBJ_NAME=s."DOMNAME" and a.MASTERLANG='S')) ml_s
go
set rowcount 15
go
select 'DD07T' tab, s."DOMNAME", s."AS4LOCAL", s."DDTEXT" texto_s, e."DDTEXT" texto_e from BAS.SAPSR3."DD07T" s noholdlock, BAS.SAPSR3."DD07T" e noholdlock where s."DDLANGUAGE" = 'S' and e."DDLANGUAGE" = 'E' and s."DOMNAME" = e."DOMNAME" and s."AS4LOCAL" = e."AS4LOCAL" and s."VALPOS" = e."VALPOS" and s."AS4VERS" = e."AS4VERS" and (s."DDTEXT" <> e."DDTEXT") and not exists (select 1 from BAS.SAPSR3.TADIR a noholdlock where a.PGMID='R3TR' and a.MASTERLANG='S' and a.OBJ_NAME=s."DOMNAME" )
go
set rowcount 0
go
select 'DD30T' tab, (select count(*) from BAS.SAPSR3."DD30T" s noholdlock, BAS.SAPSR3."DD30T" e noholdlock where s."DDLANGUAGE" = 'S' and e."DDLANGUAGE" = 'E' and s."SHLPNAME" = e."SHLPNAME" and s."AS4LOCAL" = e."AS4LOCAL" and (s."DDTEXT" <> e."DDTEXT")) s_distinto_e, (select count(*) from BAS.SAPSR3."DD30T" s noholdlock, BAS.SAPSR3."DD30T" e noholdlock where s."DDLANGUAGE" = 'S' and e."DDLANGUAGE" = 'E' and s."SHLPNAME" = e."SHLPNAME" and s."AS4LOCAL" = e."AS4LOCAL" and (s."DDTEXT" <> e."DDTEXT") and exists (select 1 from BAS.SAPSR3.TADIR a noholdlock where a.PGMID='R3TR' and a.OBJECT='SHLP' and a.OBJ_NAME=s."SHLPNAME" and a.MASTERLANG='S')) ml_s
go
set rowcount 15
go
select 'DD30T' tab, s."SHLPNAME", s."AS4LOCAL", s."DDTEXT" texto_s, e."DDTEXT" texto_e from BAS.SAPSR3."DD30T" s noholdlock, BAS.SAPSR3."DD30T" e noholdlock where s."DDLANGUAGE" = 'S' and e."DDLANGUAGE" = 'E' and s."SHLPNAME" = e."SHLPNAME" and s."AS4LOCAL" = e."AS4LOCAL" and (s."DDTEXT" <> e."DDTEXT") and not exists (select 1 from BAS.SAPSR3.TADIR a noholdlock where a.PGMID='R3TR' and a.MASTERLANG='S' and a.OBJ_NAME=s."SHLPNAME" )
go
set rowcount 0
go
select 'D020T' tab, (select count(*) from BAS.SAPSR3."D020T" s noholdlock, BAS.SAPSR3."D020T" e noholdlock where s."LANG" = 'S' and e."LANG" = 'E' and s."PROG" = e."PROG" and s."DYNR" = e."DYNR" and (s."DTXT" <> e."DTXT")) s_distinto_e, (select count(*) from BAS.SAPSR3."D020T" s noholdlock, BAS.SAPSR3."D020T" e noholdlock where s."LANG" = 'S' and e."LANG" = 'E' and s."PROG" = e."PROG" and s."DYNR" = e."DYNR" and (s."DTXT" <> e."DTXT") and exists (select 1 from BAS.SAPSR3.TADIR a noholdlock where a.PGMID='R3TR' and a.MASTERLANG='S' and ((a.OBJECT='PROG' and a.OBJ_NAME=s."PROG") or (a.OBJECT='FUGR' and s."PROG" like 'SAPL%' and a.OBJ_NAME=substring(s."PROG",5,36))))) ml_s
go
set rowcount 15
go
select 'D020T' tab, s."PROG", s."DYNR", s."DTXT" texto_s, e."DTXT" texto_e from BAS.SAPSR3."D020T" s noholdlock, BAS.SAPSR3."D020T" e noholdlock where s."LANG" = 'S' and e."LANG" = 'E' and s."PROG" = e."PROG" and s."DYNR" = e."DYNR" and (s."DTXT" <> e."DTXT") and not exists (select 1 from BAS.SAPSR3.TADIR a noholdlock where a.PGMID='R3TR' and a.MASTERLANG='S' and (a.OBJ_NAME=s."PROG" or (s."PROG" like 'SAPL%' and a.OBJ_NAME=substring(s."PROG",5,36))))
go
set rowcount 0
go
select 'D021T' tab, (select count(*) from BAS.SAPSR3."D021T" s noholdlock, BAS.SAPSR3."D021T" e noholdlock where s."LANG" = 'S' and e."LANG" = 'E' and s."PROG" = e."PROG" and s."DYNR" = e."DYNR" and s."FLDN" = e."FLDN" and (s."DTXT" <> e."DTXT")) s_distinto_e, (select count(*) from BAS.SAPSR3."D021T" s noholdlock, BAS.SAPSR3."D021T" e noholdlock where s."LANG" = 'S' and e."LANG" = 'E' and s."PROG" = e."PROG" and s."DYNR" = e."DYNR" and s."FLDN" = e."FLDN" and (s."DTXT" <> e."DTXT") and exists (select 1 from BAS.SAPSR3.TADIR a noholdlock where a.PGMID='R3TR' and a.MASTERLANG='S' and ((a.OBJECT='PROG' and a.OBJ_NAME=s."PROG") or (a.OBJECT='FUGR' and s."PROG" like 'SAPL%' and a.OBJ_NAME=substring(s."PROG",5,36))))) ml_s
go
set rowcount 15
go
select 'D021T' tab, s."PROG", s."DYNR", s."DTXT" texto_s, e."DTXT" texto_e from BAS.SAPSR3."D021T" s noholdlock, BAS.SAPSR3."D021T" e noholdlock where s."LANG" = 'S' and e."LANG" = 'E' and s."PROG" = e."PROG" and s."DYNR" = e."DYNR" and s."FLDN" = e."FLDN" and (s."DTXT" <> e."DTXT") and not exists (select 1 from BAS.SAPSR3.TADIR a noholdlock where a.PGMID='R3TR' and a.MASTERLANG='S' and (a.OBJ_NAME=s."PROG" or (s."PROG" like 'SAPL%' and a.OBJ_NAME=substring(s."PROG",5,36))))
go
set rowcount 0
go
select 'RSMPTEXTS' tab, (select count(*) from BAS.SAPSR3."RSMPTEXTS" s noholdlock, BAS.SAPSR3."RSMPTEXTS" e noholdlock where s."SPRSL" = 'S' and e."SPRSL" = 'E' and s."PROGNAME" = e."PROGNAME" and s."OBJ_TYPE" = e."OBJ_TYPE" and s."OBJ_CODE" = e."OBJ_CODE" and s."SUB_CODE" = e."SUB_CODE" and s."TEXTTYPE" = e."TEXTTYPE" and (s."TEXT" <> e."TEXT")) s_distinto_e, (select count(*) from BAS.SAPSR3."RSMPTEXTS" s noholdlock, BAS.SAPSR3."RSMPTEXTS" e noholdlock where s."SPRSL" = 'S' and e."SPRSL" = 'E' and s."PROGNAME" = e."PROGNAME" and s."OBJ_TYPE" = e."OBJ_TYPE" and s."OBJ_CODE" = e."OBJ_CODE" and s."SUB_CODE" = e."SUB_CODE" and s."TEXTTYPE" = e."TEXTTYPE" and (s."TEXT" <> e."TEXT") and exists (select 1 from BAS.SAPSR3.TADIR a noholdlock where a.PGMID='R3TR' and a.MASTERLANG='S' and ((a.OBJECT='PROG' and a.OBJ_NAME=s."PROGNAME") or (a.OBJECT='FUGR' and s."PROGNAME" like 'SAPL%' and a.OBJ_NAME=substring(s."PROGNAME",5,36))))) ml_s
go
set rowcount 15
go
select 'RSMPTEXTS' tab, s."PROGNAME", s."OBJ_TYPE", s."TEXT" texto_s, e."TEXT" texto_e from BAS.SAPSR3."RSMPTEXTS" s noholdlock, BAS.SAPSR3."RSMPTEXTS" e noholdlock where s."SPRSL" = 'S' and e."SPRSL" = 'E' and s."PROGNAME" = e."PROGNAME" and s."OBJ_TYPE" = e."OBJ_TYPE" and s."OBJ_CODE" = e."OBJ_CODE" and s."SUB_CODE" = e."SUB_CODE" and s."TEXTTYPE" = e."TEXTTYPE" and (s."TEXT" <> e."TEXT") and not exists (select 1 from BAS.SAPSR3.TADIR a noholdlock where a.PGMID='R3TR' and a.MASTERLANG='S' and (a.OBJ_NAME=s."PROGNAME" or (s."PROGNAME" like 'SAPL%' and a.OBJ_NAME=substring(s."PROGNAME",5,36))))
go
set rowcount 0
go
select 'CUS_IMGACT' tab, (select count(*) from BAS.SAPSR3."CUS_IMGACT" s noholdlock, BAS.SAPSR3."CUS_IMGACT" e noholdlock where s."SPRAS" = 'S' and e."SPRAS" = 'E' and s."ACTIVITY" = e."ACTIVITY" and (s."TEXT" <> e."TEXT")) s_distinto_e, 0 ml_s
go
set rowcount 15
go
select 'CUS_IMGACT' tab, s."ACTIVITY", s."TEXT" texto_s, e."TEXT" texto_e from BAS.SAPSR3."CUS_IMGACT" s noholdlock, BAS.SAPSR3."CUS_IMGACT" e noholdlock where s."SPRAS" = 'S' and e."SPRAS" = 'E' and s."ACTIVITY" = e."ACTIVITY" and (s."TEXT" <> e."TEXT")
go
set rowcount 0
go
select 'fin', getdate()
go
