REPORT ztrad_multi.
*----------------------------------------------------------------------*
* Traduccion EN -> ES de varias tablas de textos a la vez.
* Para cada tabla con campo de idioma clave (tipo LANG) se exportan
* todos los campos CHAR no clave de longitud >= P_MINL cuya fila ES
* falta, esta vacia o es igual a la EN.
* Archivo: SRC(tabla-campo) KEY(claves sep. por |) MAXLEN EN ES
* _final: P_SRV/P_MEM (ocultos) para correr en fondo por ZCL_ZTRAD_HTTP
*----------------------------------------------------------------------*
TYPES: BEGIN OF ty_kx,
         k TYPE string,
         i TYPE i,
       END OF ty_kx.

DATA: gt_file TYPE STANDARD TABLE OF string,
      gv_row  TYPE string,
      gv_tab  TYPE c,
      gv_cnt  TYPE i,
      gv_tabn TYPE tabname.

SELECT-OPTIONS s_tab FOR gv_tabn NO INTERVALS.
PARAMETERS: r_exp  RADIOBUTTON GROUP mod DEFAULT 'X',
            r_imp  RADIOBUTTON GROUP mod,
            p_test AS CHECKBOX DEFAULT 'X',
            p_minl TYPE i DEFAULT 10,
            p_file TYPE string LOWER CASE
                   DEFAULT 'C:\Users\user\Documents\ztrad_multi.txt'.
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
FORM get_meta USING pv_tab TYPE tabname
              CHANGING ct_keys TYPE string_table
                       ct_flds TYPE string_table
                       cv_lang TYPE string.
  DATA: lt_f TYPE STANDARD TABLE OF dd03l,
        ls_f TYPE dd03l.
  REFRESH: ct_keys, ct_flds.
  CLEAR cv_lang.
  SELECT * FROM dd03l INTO TABLE lt_f
    WHERE tabname = pv_tab AND as4local = 'A'
    ORDER BY position.
  LOOP AT lt_f INTO ls_f.
    CHECK ls_f-fieldname(1) <> '.'.
    IF ls_f-keyflag = 'X'.
      IF ls_f-datatype = 'CLNT'.
        CONTINUE.
      ELSEIF ls_f-datatype = 'LANG' AND cv_lang IS INITIAL.
        cv_lang = ls_f-fieldname.
      ELSE.
        APPEND ls_f-fieldname TO ct_keys.
      ENDIF.
    ELSEIF ls_f-datatype = 'CHAR' AND ls_f-leng >= p_minl.
      APPEND ls_f-fieldname TO ct_flds.
    ENDIF.
  ENDLOOP.
ENDFORM.

FORM keystr USING is_row TYPE any it_keys TYPE string_table
            CHANGING cv_key TYPE string.
  DATA lv_f TYPE string.
  DATA lv_v TYPE string.
  FIELD-SYMBOLS <f> TYPE any.
  CLEAR cv_key.
  LOOP AT it_keys INTO lv_f.
    ASSIGN COMPONENT lv_f OF STRUCTURE is_row TO <f>.
    lv_v = <f>.
    IF sy-tabix = 1.
      cv_key = lv_v.
    ELSE.
      CONCATENATE cv_key '|' lv_v INTO cv_key.
    ENDIF.
  ENDLOOP.
ENDFORM.

*----------------------------------------------------------------------*
FORM export.
  DATA: lt_dd02 TYPE STANDARD TABLE OF dd02l,
        ls_dd02 TYPE dd02l,
        lt_keys TYPE string_table,
        lt_flds TYPE string_table,
        lv_lang TYPE string,
        lv_fld  TYPE string,
        lv_wh   TYPE string,
        lv_key  TYPE string,
        lv_src  TYPE string,
        lv_len  TYPE string,
        lv_l    TYPE i,
        lv_te   TYPE string,
        lv_ts   TYPE string,
        lv_tabc TYPE i,
        lt_kx   TYPE HASHED TABLE OF ty_kx WITH UNIQUE KEY k,
        ls_kx   TYPE ty_kx,
        lr_e    TYPE REF TO data,
        lr_s    TYPE REF TO data.
  FIELD-SYMBOLS: <et> TYPE STANDARD TABLE,
                 <st> TYPE STANDARD TABLE,
                 <w>  TYPE any,
                 <ws> TYPE any,
                 <t>  TYPE any.

  CONCATENATE 'SRC' 'KEY' 'MAXLEN' 'EN' 'ES' INTO gv_row
    SEPARATED BY gv_tab.
  APPEND gv_row TO gt_file.

  SELECT * FROM dd02l INTO TABLE lt_dd02
    WHERE tabname IN s_tab AND as4local = 'A' AND tabclass = 'TRANSP'.
  SORT lt_dd02 BY tabname.

  LOOP AT lt_dd02 INTO ls_dd02.
    PERFORM get_meta USING ls_dd02-tabname
                     CHANGING lt_keys lt_flds lv_lang.
    CHECK lv_lang IS NOT INITIAL.
    CHECK lt_flds IS NOT INITIAL.
    ADD 1 TO lv_tabc.

    CREATE DATA lr_e TYPE STANDARD TABLE OF (ls_dd02-tabname).
    CREATE DATA lr_s TYPE STANDARD TABLE OF (ls_dd02-tabname).
    ASSIGN lr_e->* TO <et>.
    ASSIGN lr_s->* TO <st>.
    CONCATENATE lv_lang ` = 'E'` INTO lv_wh.
    SELECT * FROM (ls_dd02-tabname) INTO TABLE <et> WHERE (lv_wh).
    CONCATENATE lv_lang ` = 'S'` INTO lv_wh.
    SELECT * FROM (ls_dd02-tabname) INTO TABLE <st> WHERE (lv_wh).

    REFRESH lt_kx.
    LOOP AT <st> ASSIGNING <w>.
      PERFORM keystr USING <w> lt_keys CHANGING ls_kx-k.
      ls_kx-i = sy-tabix.
      INSERT ls_kx INTO TABLE lt_kx.
    ENDLOOP.

    LOOP AT <et> ASSIGNING <w>.
      PERFORM keystr USING <w> lt_keys CHANGING lv_key.
      READ TABLE lt_kx INTO ls_kx WITH TABLE KEY k = lv_key.
      IF sy-subrc = 0.
        READ TABLE <st> ASSIGNING <ws> INDEX ls_kx-i.
      ELSE.
        UNASSIGN <ws>.
      ENDIF.
      LOOP AT lt_flds INTO lv_fld.
        ASSIGN COMPONENT lv_fld OF STRUCTURE <w> TO <t>.
        CHECK <t> IS NOT INITIAL.
        lv_te = <t>.
        CLEAR lv_ts.
        IF <ws> IS ASSIGNED.
          ASSIGN COMPONENT lv_fld OF STRUCTURE <ws> TO <t>.
          lv_ts = <t>.
        ENDIF.
        IF lv_ts IS NOT INITIAL AND lv_ts <> lv_te.
          CONTINUE.
        ENDIF.
        ASSIGN COMPONENT lv_fld OF STRUCTURE <w> TO <t>.
        DESCRIBE FIELD <t> LENGTH lv_l IN CHARACTER MODE.
        lv_len = lv_l. CONDENSE lv_len.
        CONCATENATE ls_dd02-tabname '-' lv_fld INTO lv_src.
        REPLACE ALL OCCURRENCES OF gv_tab IN lv_te WITH ` `.
        CONCATENATE lv_src lv_key lv_len lv_te lv_te INTO gv_row
          SEPARATED BY gv_tab.
        APPEND gv_row TO gt_file.
        ADD 1 TO gv_cnt.
      ENDLOOP.
    ENDLOOP.
  ENDLOOP.

  DATA lv_rc TYPE i.
  PERFORM file_write CHANGING lv_rc.
  IF lv_rc = 0.
    WRITE: / 'Tablas procesadas:', lv_tabc,
           / 'Textos exportados:', gv_cnt.
  ENDIF.
ENDFORM.

*----------------------------------------------------------------------*
FORM import.
  DATA: lv_src  TYPE string,
        lv_key  TYPE string,
        lv_ml   TYPE string,
        lv_en   TYPE string,
        lv_es   TYPE string,
        lv_tabs TYPE string,
        lv_tab  TYPE tabname,
        lv_fld  TYPE string,
        lv_ptab TYPE tabname,
        lt_keys TYPE string_table,
        lt_flds TYPE string_table,
        lv_lang TYPE string,
        lt_val  TYPE string_table,
        lv_f    TYPE string,
        lv_v    TYPE string,
        lv_wh   TYPE string,
        lv_ok   TYPE i,
        lv_err  TYPE i,
        lv_max  TYPE i,
        lv_len  TYPE i,
        lr_w    TYPE REF TO data.
  FIELD-SYMBOLS: <w> TYPE any,
                 <f> TYPE any.

  PERFORM file_read CHANGING lv_err.
  IF lv_err <> 0.
    RETURN.
  ENDIF.

  LOOP AT gt_file INTO gv_row.
    CHECK sy-tabix > 1.
    CHECK gv_row IS NOT INITIAL.
    CLEAR: lv_src, lv_key, lv_ml, lv_en, lv_es.
    SPLIT gv_row AT gv_tab INTO lv_src lv_key lv_ml lv_en lv_es.
    CHECK lv_es IS NOT INITIAL.
*   (filas iguales se graban igual: crean la fila ES si falta)
    lv_max = lv_ml.
    lv_len = strlen( lv_es ).
    IF lv_len > lv_max.
      WRITE: / 'Demasiado largo:', lv_src, lv_key, lv_len, lv_max.
      ADD 1 TO lv_err.
      CONTINUE.
    ENDIF.
    SPLIT lv_src AT '-' INTO lv_tabs lv_fld.
    lv_tab = lv_tabs.
    IF lv_tab <> lv_ptab.
      PERFORM get_meta USING lv_tab CHANGING lt_keys lt_flds lv_lang.
      lv_ptab = lv_tab.
    ENDIF.
    IF lv_lang IS INITIAL.
      WRITE: / 'Tabla sin idioma:', lv_tab.
      ADD 1 TO lv_err.
      CONTINUE.
    ENDIF.

    REFRESH lt_val.
    SPLIT lv_key AT '|' INTO TABLE lt_val.
    CONCATENATE lv_lang ` = 'E'` INTO lv_wh.
    LOOP AT lt_keys INTO lv_f.
      CLEAR lv_v.
      READ TABLE lt_val INTO lv_v INDEX sy-tabix.
      REPLACE ALL OCCURRENCES OF `'` IN lv_v WITH `''`.
      IF lv_v IS INITIAL.
        lv_v = ` `.
      ENDIF.
      CONCATENATE lv_wh ` AND ` lv_f ` = '` lv_v `'` INTO lv_wh.
    ENDLOOP.
    CREATE DATA lr_w TYPE (lv_tab).
    ASSIGN lr_w->* TO <w>.
    SELECT SINGLE * FROM (lv_tab) INTO <w> WHERE (lv_wh).
    IF sy-subrc <> 0.
      WRITE: / 'Fila EN no encontrada:', lv_src, lv_key.
      ADD 1 TO lv_err.
      CONTINUE.
    ENDIF.
*   Si ya existe la fila ES se parte de ella (no pisar otros campos)
    REPLACE FIRST OCCURRENCE OF `= 'E'` IN lv_wh WITH `= 'S'`.
    SELECT SINGLE * FROM (lv_tab) INTO <w> WHERE (lv_wh).
    ASSIGN COMPONENT lv_lang OF STRUCTURE <w> TO <f>.
    <f> = 'S'.
    ASSIGN COMPONENT lv_fld OF STRUCTURE <w> TO <f>.
    IF sy-subrc <> 0.
      WRITE: / 'Campo no existe:', lv_src.
      ADD 1 TO lv_err.
      CONTINUE.
    ENDIF.
    <f> = lv_es.
    IF p_test IS INITIAL.
      MODIFY (lv_tab) FROM <w>.
    ENDIF.
    ADD 1 TO lv_ok.
  ENDLOOP.

  IF p_test IS INITIAL.
    COMMIT WORK.
  ENDIF.
  WRITE: / 'Textos actualizados:', lv_ok,
         / 'Errores:', lv_err.
  IF p_test = 'X'.
    WRITE: / '(modo prueba, no se grabo nada)'.
  ENDIF.
ENDFORM.

*----------------------------------------------------------------------*
* E/S de archivo comun (_final): P_SRV > P_MEM > archivo del frontend.
* P_SRV: ruta relativa a C:\Users\user\Documents\ztrad_rfc_files\
*        (OPEN DATASET, UTF-8 con BOM, CRLF), para correr en fondo.
* P_MEM: datos en INDX(ZT) (servicio HTTP ZCL_ZTRAD_HTTP).
* Sin ninguno de los dos: GUI_UPLOAD/GUI_DOWNLOAD de P_FILE (SAP GUI).
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

FORM file_read CHANGING cv_rc TYPE i.
  DATA: lv_path TYPE string,
        lv_line TYPE string.
  cv_rc = 0.
  REFRESH gt_file.
  IF p_srv IS NOT INITIAL.
    PERFORM srv_path CHANGING lv_path cv_rc.
    IF cv_rc <> 0.
      RETURN.
    ENDIF.
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
  ELSEIF p_mem IS NOT INITIAL.
    IMPORT data = gt_file FROM DATABASE indx(zt) ID p_mem.
    IF sy-subrc <> 0.
      WRITE: / 'No hay datos en INDX(ZT) para', p_mem.
      cv_rc = 1.
      RETURN.
    ENDIF.
*   El cuerpo HTTP se parte por LF: quitar el CR final de cada linea
    LOOP AT gt_file INTO lv_line.
      REPLACE ALL OCCURRENCES OF cl_abap_char_utilities=>cr_lf(1)
        IN lv_line WITH ``.
      MODIFY gt_file FROM lv_line.
    ENDLOOP.
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
      cv_rc = 1.
    ENDIF.
  ENDIF.
ENDFORM.

FORM file_write CHANGING cv_rc TYPE i.
  DATA: lv_path TYPE string,
        lv_line TYPE string.
  cv_rc = 0.
  IF p_srv IS NOT INITIAL.
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
    LOOP AT gt_file INTO lv_line.
      TRANSFER lv_line TO lv_path.
    ENDLOOP.
    CLOSE DATASET lv_path.
    WRITE: / 'Archivo servidor:', c_base, p_srv.
  ELSEIF p_mem IS NOT INITIAL.
    EXPORT data = gt_file TO DATABASE indx(zt) ID p_mem.
    cv_rc = sy-subrc.
    COMMIT WORK.
    WRITE: / 'Datos en INDX(ZT):', p_mem.
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
    cv_rc = sy-subrc.
    IF cv_rc = 0.
      WRITE: / 'Archivo:', p_file.
    ENDIF.
  ENDIF.
  IF cv_rc <> 0.
    WRITE: / 'Error al grabar el archivo'.
  ENDIF.
ENDFORM.
