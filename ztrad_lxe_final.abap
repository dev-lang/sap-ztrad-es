REPORT ztrad_lxe.
*----------------------------------------------------------------------*
* Traduccion EN -> ES de objetos de repositorio via API LXE (SE63)
* Exporta pares de texto a TSV (UTF-8) y los reimporta traducidos.
* Tipos probados: TRAN, DTEL, MESS, RPT4, SRT4, CA4, CA1, RPT1, SRT1
* v9: graba el objeto completo (no borra textos ausentes del archivo)
*     P_SAME: acepta lineas con ES = EN (restaurar copias EN)
* v10: P_MEM (oculto): datos en INDX(ZT) en vez de archivo del frontend,
*      para ejecucion en fondo desde el servicio HTTP ZCL_ZTRAD_HTTP
* v11: P_SRV (oculto): archivo en la PC/servidor bajo ztrad_rfc_files\
*      (OPEN DATASET), para lotes grandes sin pasar por HTTP
*----------------------------------------------------------------------*

TYPES: BEGIN OF ty_line,
         objtype TYPE lxeobjtype,
         objname TYPE lxeobjname,
         textkey TYPE lxetextkey,
         unitmlt TYPE lxeunitmlt,
         s_text  TYPE lxeunitlin,
         t_text  TYPE lxeunitlin,
       END OF ty_line,
       BEGIN OF ty_dynp,
         prog TYPE d020s-prog,
         dnum TYPE d020s-dnum,
       END OF ty_dynp,
       BEGIN OF ty_t100k,
         arbgb TYPE arbgb,
         msgnr TYPE msgnr,
       END OF ty_t100k.

CONSTANTS: c_slang TYPE lxeisolang VALUE 'enUS',
           c_tlang TYPE lxeisolang VALUE 'esES',
           c_cust  TYPE lxecustmnr VALUE '999999'.

DATA: gt_lines   TYPE STANDARD TABLE OF ty_line,
      gs_line    TYPE ty_line,
      gt_file    TYPE STANDARD TABLE OF string,
      gv_row     TYPE string,
      gt_objs    TYPE STANDARD TABLE OF lxeobjname,
      gv_obj     TYPE lxeobjname,
      gt_pcx     TYPE STANDARD TABLE OF lxe_pcx_s1,
      gt_pcx_w   TYPE STANDARD TABLE OF lxe_pcx_s1,
      gs_pcx     TYPE lxe_pcx_s1,
      gv_pstatus TYPE lxestatprc,
      gv_name    TYPE char40,
      gv_tabn    TYPE tabname,
      gv_tab     TYPE c.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME.
PARAMETERS p_type TYPE lxeobjtype OBLIGATORY DEFAULT 'TRAN'.
SELECT-OPTIONS s_name FOR gv_name.
SELECT-OPTIONS s_tab  FOR gv_tabn.
PARAMETERS: p_max  TYPE i DEFAULT 500,
            p_pend AS CHECKBOX DEFAULT 'X'.
SELECTION-SCREEN END OF BLOCK b1.

SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME.
PARAMETERS: r_exp  RADIOBUTTON GROUP g1 DEFAULT 'X',
            r_imp  RADIOBUTTON GROUP g1,
            p_test AS CHECKBOX DEFAULT 'X',
            p_same AS CHECKBOX,
            p_file TYPE string LOWER CASE DEFAULT 'C:\temp\ztrad_export.txt'.
SELECTION-SCREEN END OF BLOCK b2.
PARAMETERS p_mem TYPE indx-srtfd NO-DISPLAY.
PARAMETERS p_srv TYPE char45 LOWER CASE NO-DISPLAY.
CONSTANTS c_base TYPE string VALUE 'C:\Users\user\Documents\ztrad_rfc_files\'.

START-OF-SELECTION.
  gv_tab = cl_abap_char_utilities=>horizontal_tab.
  IF r_exp = 'X'.
    PERFORM export.
  ELSE.
    PERFORM import.
  ENDIF.

*----------------------------------------------------------------------*
FORM get_objects.
  DATA: lt_tcode TYPE STANDARD TABLE OF tcode,
        lv_tcode TYPE tcode,
        lt_dtel  TYPE STANDARD TABLE OF rollname,
        lv_dtel  TYPE rollname,
        lt_prog  TYPE STANDARD TABLE OF progname,
        lv_prog  TYPE progname,
        lt_t100  TYPE STANDARD TABLE OF ty_t100k,
        ls_t100  TYPE ty_t100k,
        lt_dynp  TYPE STANDARD TABLE OF ty_dynp,
        ls_dynp  TYPE ty_dynp.

  REFRESH gt_objs.
  CASE p_type.
    WHEN 'TRAN'.
      SELECT tcode FROM tstc INTO TABLE lt_tcode UP TO p_max ROWS
        WHERE tcode IN s_name ORDER BY tcode.
      LOOP AT lt_tcode INTO lv_tcode.
        gv_obj = lv_tcode.
        APPEND gv_obj TO gt_objs.
      ENDLOOP.
    WHEN 'DTEL'.
      IF s_tab[] IS NOT INITIAL.
*       Elementos de datos usados en las tablas/estructuras indicadas
        SELECT DISTINCT rollname FROM dd03l INTO TABLE lt_dtel
          UP TO p_max ROWS
          WHERE tabname IN s_tab AND as4local = 'A'
            AND rollname <> space AND rollname IN s_name
          ORDER BY rollname.
      ELSE.
        SELECT rollname FROM dd04l INTO TABLE lt_dtel UP TO p_max ROWS
          WHERE rollname IN s_name AND as4local = 'A' AND as4vers = '0000'
          ORDER BY rollname.
      ENDIF.
      LOOP AT lt_dtel INTO lv_dtel.
        gv_obj = lv_dtel.
        APPEND gv_obj TO gt_objs.
      ENDLOOP.
    WHEN 'RPT4'.
      SELECT name FROM trdir INTO TABLE lt_prog UP TO p_max ROWS
        WHERE name IN s_name ORDER BY name.
      LOOP AT lt_prog INTO lv_prog.
        gv_obj = lv_prog.
        APPEND gv_obj TO gt_objs.
      ENDLOOP.
    WHEN 'MESS'.
      SELECT arbgb msgnr FROM t100 INTO TABLE lt_t100 UP TO p_max ROWS
        WHERE sprsl = 'E' AND arbgb IN s_name ORDER BY arbgb msgnr.
      LOOP AT lt_t100 INTO ls_t100.
        CLEAR gv_obj.
        gv_obj(20)    = ls_t100-arbgb.
        gv_obj+20(3)  = ls_t100-msgnr.
        APPEND gv_obj TO gt_objs.
      ENDLOOP.
    WHEN 'SRT4'.
*     Todas las pantallas de los programas indicados: prog(40) + dynnr
      SELECT prog dnum FROM d020s INTO TABLE lt_dynp UP TO p_max ROWS
        WHERE prog IN s_name ORDER BY prog dnum.
      LOOP AT lt_dynp INTO ls_dynp.
        CLEAR gv_obj.
        gv_obj(40)   = ls_dynp-prog.
        gv_obj+40(4) = ls_dynp-dnum.
        APPEND gv_obj TO gt_objs.
      ENDLOOP.
    WHEN 'SRT1'.
*     Pantallas de grupos de funciones: s_name = grupo de funciones.
*     Se generan dos formatos candidatos: grupo(40)+dynnr y grupo(26)+dynnr
      LOOP AT s_name.
        CONCATENATE 'SAPL' s_name-low INTO lv_prog.
        SELECT prog dnum FROM d020s INTO TABLE lt_dynp UP TO p_max ROWS
          WHERE prog = lv_prog ORDER BY prog dnum.
        LOOP AT lt_dynp INTO ls_dynp.
          CLEAR gv_obj.
          gv_obj(40)   = s_name-low.
          gv_obj+40(4) = ls_dynp-dnum.
          APPEND gv_obj TO gt_objs.
          CLEAR gv_obj.
          gv_obj(26)   = s_name-low.
          gv_obj+26(4) = ls_dynp-dnum.
          APPEND gv_obj TO gt_objs.
        ENDLOOP.
      ENDLOOP.
    WHEN OTHERS.
      LOOP AT s_name.
        gv_obj = s_name-low.
        APPEND gv_obj TO gt_objs.
      ENDLOOP.
  ENDCASE.
ENDFORM.

*----------------------------------------------------------------------*
FORM export.
  DATA: lv_unit TYPE string,
        lv_cnt  TYPE i,
        lv_objs TYPE i,
        lv_rc   TYPE i.

  IF s_name[] IS INITIAL AND s_tab[] IS INITIAL.
    MESSAGE 'Indicar al menos un nombre o patron en S_NAME' TYPE 'S' DISPLAY LIKE 'E'.
    RETURN.
  ENDIF.

  PERFORM get_objects.

  REFRESH gt_file.
  CONCATENATE 'OBJTYPE' 'OBJNAME' 'TEXTKEY' 'MAXLEN' 'EN' 'ES'
    INTO gv_row SEPARATED BY gv_tab.
  APPEND gv_row TO gt_file.

  LOOP AT gt_objs INTO gv_obj.
    REFRESH gt_pcx.
    CALL FUNCTION 'LXE_OBJ_TEXT_PAIR_READ'
      EXPORTING
        t_lang    = c_tlang
        s_lang    = c_slang
        custmnr   = c_cust
        objtype   = p_type
        objname   = gv_obj
      IMPORTING
        pstatus   = gv_pstatus
      TABLES
        lt_pcx_s1 = gt_pcx.

    LOOP AT gt_pcx INTO gs_pcx.
      IF gs_pcx-s_text IS INITIAL.
        CONTINUE.
      ENDIF.
      IF p_pend = 'X' AND gs_pcx-t_text IS NOT INITIAL
         AND gs_pcx-t_text <> gs_pcx-s_text.
        CONTINUE.
      ENDIF.
      lv_unit = gs_pcx-unitmlt.
      CONDENSE lv_unit.
      CONCATENATE p_type gv_obj gs_pcx-textkey lv_unit
                  gs_pcx-s_text gs_pcx-t_text
        INTO gv_row SEPARATED BY gv_tab.
      APPEND gv_row TO gt_file.
      ADD 1 TO lv_cnt.
    ENDLOOP.
  ENDLOOP.

  IF p_srv IS NOT INITIAL.
    PERFORM srv_write CHANGING lv_rc.
  ELSEIF p_mem IS NOT INITIAL.
    EXPORT data = gt_file TO DATABASE indx(zt) ID p_mem.
    lv_rc = sy-subrc.
    COMMIT WORK.
  ELSE.
    CALL METHOD cl_gui_frontend_services=>gui_download
      EXPORTING
        filename  = p_file
        filetype  = 'ASC'
        codepage  = '4110'
        write_bom = 'X'
      CHANGING
        data_tab  = gt_file
      EXCEPTIONS
        OTHERS    = 1.
    lv_rc = sy-subrc.
  ENDIF.

  DESCRIBE TABLE gt_objs LINES lv_objs.
  IF lv_rc <> 0.
    WRITE: / 'Error al grabar el archivo', p_file.
  ELSE.
    WRITE: / 'Objetos leidos:', lv_objs,
           / 'Textos exportados:', lv_cnt.
    IF p_srv IS NOT INITIAL.
      WRITE: / 'Archivo servidor:', c_base, p_srv.
    ELSEIF p_mem IS NOT INITIAL.
      WRITE: / 'Datos en INDX(ZT):', p_mem.
    ELSE.
      WRITE: / 'Archivo:', p_file.
    ENDIF.
  ENDIF.
ENDFORM.

*----------------------------------------------------------------------*
FORM import.
  DATA: lv_all      TYPE string,
        lv_ml       TYPE string,
        lv_len      TYPE i,
        lv_ok       TYPE i,
        lv_err      TYPE i,
        lv_prevtype TYPE lxeobjtype,
        lv_prevname TYPE lxeobjname,
        lv_idx      TYPE sytabix.

  IF p_srv IS NOT INITIAL.
    PERFORM srv_read CHANGING lv_err.
    IF lv_err <> 0.
      RETURN.
    ENDIF.
  ELSEIF p_mem IS NOT INITIAL.
    IMPORT data = gt_file FROM DATABASE indx(zt) ID p_mem.
    IF sy-subrc <> 0.
      WRITE: / 'No hay datos en INDX(ZT) para', p_mem.
      RETURN.
    ENDIF.
  ELSE.
    CALL METHOD cl_gui_frontend_services=>gui_upload
      EXPORTING
        filename = p_file
        filetype = 'ASC'
        codepage = '4110'
      CHANGING
        data_tab = gt_file
      EXCEPTIONS
        OTHERS   = 1.
    IF sy-subrc <> 0.
      WRITE: / 'Error al leer el archivo', p_file.
      RETURN.
    ENDIF.
  ENDIF.

* Normalizar saltos de linea (CRLF / LF) por si llega todo en una linea
  CLEAR lv_all.
  LOOP AT gt_file INTO gv_row.
    IF sy-tabix > 1.
      CONCATENATE lv_all cl_abap_char_utilities=>newline INTO lv_all.
    ENDIF.
    CONCATENATE lv_all gv_row INTO lv_all.
  ENDLOOP.
  REPLACE ALL OCCURRENCES OF cl_abap_char_utilities=>cr_lf
    IN lv_all WITH cl_abap_char_utilities=>newline.
  REFRESH gt_file.
  SPLIT lv_all AT cl_abap_char_utilities=>newline INTO TABLE gt_file.

  DESCRIBE TABLE gt_file LINES lv_len.
  WRITE: / 'Lineas leidas del archivo:', lv_len.

  REFRESH gt_lines.
  LOOP AT gt_file INTO gv_row.
    IF sy-tabix = 1.
      CONTINUE.
    ENDIF.
    CLEAR: gs_line, lv_ml.
    SPLIT gv_row AT gv_tab INTO gs_line-objtype gs_line-objname
          gs_line-textkey lv_ml gs_line-s_text gs_line-t_text.
    IF gs_line-t_text IS INITIAL OR
       ( gs_line-t_text = gs_line-s_text AND p_same IS INITIAL ).
      IF lv_err < 3.
        WRITE: / 'Linea descartada:', gs_line-objname(20), '|', gs_line-t_text(40).
      ENDIF.
      ADD 1 TO lv_err.
      CONTINUE.
    ENDIF.
    gs_line-unitmlt = lv_ml.
    APPEND gs_line TO gt_lines.
  ENDLOOP.

  WRITE: / 'Lineas descartadas (sin traduccion):', lv_err.
  CLEAR lv_err.

  SORT gt_lines BY objtype objname textkey.

  IF p_test = 'X'.
    WRITE: / '*** MODO TEST: no se graba nada ***'.
    ULINE.
  ENDIF.

  LOOP AT gt_lines INTO gs_line.
    IF gs_line-objtype <> lv_prevtype OR gs_line-objname <> lv_prevname.
      IF lv_prevname IS NOT INITIAL.
        PERFORM write_obj USING lv_prevtype lv_prevname.
      ENDIF.
      lv_prevtype = gs_line-objtype.
      lv_prevname = gs_line-objname.
      REFRESH: gt_pcx, gt_pcx_w.
      CALL FUNCTION 'LXE_OBJ_TEXT_PAIR_READ'
        EXPORTING
          t_lang    = c_tlang
          s_lang    = c_slang
          custmnr   = c_cust
          objtype   = gs_line-objtype
          objname   = gs_line-objname
          read_only = ' '
        IMPORTING
          pstatus   = gv_pstatus
        TABLES
          lt_pcx_s1 = gt_pcx.
    ENDIF.

    READ TABLE gt_pcx INTO gs_pcx WITH KEY textkey = gs_line-textkey.
    lv_idx = sy-tabix.
    IF sy-subrc <> 0.
      WRITE: / 'Clave no encontrada:', gs_line-objtype,
               gs_line-objname(40), gs_line-textkey.
      ADD 1 TO lv_err.
      CONTINUE.
    ENDIF.

    lv_len = strlen( gs_line-t_text ).
    IF gs_pcx-unitmlt > 0 AND lv_len > gs_pcx-unitmlt.
      WRITE: / 'Texto demasiado largo (', lv_len, '>', gs_pcx-unitmlt, '):',
               gs_line-objname(40), gs_line-textkey.
      ADD 1 TO lv_err.
      CONTINUE.
    ENDIF.

    IF gs_pcx-uppcase = 'X' OR gs_pcx-uppcase = '1'.
      TRANSLATE gs_line-t_text TO UPPER CASE.
    ENDIF.

    gs_pcx-t_text = gs_line-t_text.
* v9: actualizar el registro completo leido para no borrar en ES
* los textos del objeto que no vienen en el archivo (ej. DTEL)
    MODIFY gt_pcx FROM gs_pcx INDEX lv_idx TRANSPORTING t_text.
    APPEND gs_pcx TO gt_pcx_w.
    ADD 1 TO lv_ok.

    IF p_test = 'X'.
      WRITE: / gs_line-objname(30), gs_line-textkey(20), gs_line-t_text(80).
    ENDIF.
  ENDLOOP.

  IF lv_prevname IS NOT INITIAL.
    PERFORM write_obj USING lv_prevtype lv_prevname.
  ENDIF.

  IF p_test IS INITIAL.
    COMMIT WORK.
*   Invalidar cargas de textos de pantallas en ES para que se regeneren
*   con las traducciones nuevas (DB_DROP_DYNP_TEXT_LOADS no soporta Sybase)
    EXEC SQL.
      DELETE FROM DYNPTXTLD WHERE LANGUAGE = 'S'
    ENDEXEC.
    lv_len = sy-dbcnt.
    COMMIT WORK.
    WRITE: / 'Cargas de textos de pantallas ES invalidadas:', lv_len.
    WRITE: / 'Para verlo en sesiones abiertas, ejecutar /$SYNC.'.
  ENDIF.

  ULINE.
  WRITE: / 'Textos OK:', lv_ok,
         / 'Textos con error:', lv_err.
ENDFORM.

*----------------------------------------------------------------------*
FORM write_obj USING pv_type TYPE lxeobjtype
                     pv_name TYPE lxeobjname.
  DATA: lv_n   TYPE i,
        lv_cua TYPE progname.

  DESCRIBE TABLE gt_pcx_w LINES lv_n.
  IF lv_n = 0 OR p_test = 'X'.
    RETURN.
  ENDIF.

  CALL FUNCTION 'LXE_OBJ_TEXT_PAIR_WRITE'
    EXPORTING
      t_lang    = c_tlang
      s_lang    = c_slang
      custmnr   = c_cust
      objtype   = pv_type
      objname   = pv_name
    IMPORTING
      pstatus   = gv_pstatus
    TABLES
      lt_pcx_s1 = gt_pcx.

  WRITE: / pv_type, pv_name(40), lv_n, 'textos - status:', gv_pstatus.

* Textos de interfaz (menus/botones/titulos): invalidar carga CUA
  IF pv_type(2) = 'CA'.
    lv_cua = pv_name(40).
    IF pv_type = 'CA1'.
      CONCATENATE 'SAPL' pv_name(36) INTO lv_cua.
    ENDIF.
    CALL FUNCTION 'RS_CUA_DELETE_TEXT_LOAD'
      EXPORTING
        language       = 'S'
        name           = lv_cua
        suppress_check = 'X'
      EXCEPTIONS
        OTHERS         = 1.
  ENDIF.
ENDFORM.

*----------------------------------------------------------------------*
* Archivos en el servidor (SAP corre en la misma PC): P_SRV es relativo
* a C:\Users\user\Documents\ztrad_rfc_files\ (ej. rfcimport\lote1.txt)
*----------------------------------------------------------------------*
FORM srv_path CHANGING cv_path TYPE string cv_rc TYPE i.
  cv_rc = 0.
  IF p_srv CS '..' OR p_srv CS ':' OR p_srv(1) = '\' OR p_srv(1) = '/'.
    WRITE: / 'Ruta no permitida:', p_srv.
    cv_rc = 1.
    RETURN.
  ENDIF.
  CONCATENATE c_base p_srv INTO cv_path.
ENDFORM.

FORM srv_read CHANGING cv_rc TYPE i.
  DATA: lv_path TYPE string,
        lv_line TYPE string.
  PERFORM srv_path CHANGING lv_path cv_rc.
  IF cv_rc <> 0.
    RETURN.
  ENDIF.
  REFRESH gt_file.
  OPEN DATASET lv_path FOR INPUT IN TEXT MODE ENCODING UTF-8
    SKIPPING BYTE-ORDER MARK WITH WINDOWS LINEFEED.
  IF sy-subrc <> 0.
    WRITE: / 'No se pudo abrir el archivo', lv_path.
    cv_rc = 1.
    RETURN.
  ENDIF.
  DO.
    READ DATASET lv_path INTO lv_line.
    IF sy-subrc <> 0.
      EXIT.
    ENDIF.
    APPEND lv_line TO gt_file.
  ENDDO.
  CLOSE DATASET lv_path.
ENDFORM.

FORM srv_write CHANGING cv_rc TYPE i.
  DATA lv_path TYPE string.
  PERFORM srv_path CHANGING lv_path cv_rc.
  IF cv_rc <> 0.
    RETURN.
  ENDIF.
  OPEN DATASET lv_path FOR OUTPUT IN TEXT MODE ENCODING UTF-8
    WITH BYTE-ORDER MARK WITH WINDOWS LINEFEED.
  IF sy-subrc <> 0.
    WRITE: / 'No se pudo crear el archivo', lv_path.
    cv_rc = 1.
    RETURN.
  ENDIF.
  LOOP AT gt_file INTO gv_row.
    TRANSFER gv_row TO lv_path.
  ENDLOOP.
  CLOSE DATASET lv_path.
ENDFORM.
