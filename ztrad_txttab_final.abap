REPORT ztrad_txttab.
*----------------------------------------------------------------------*
* Traduccion EN -> ES de tablas de textos leidas en ejecucion:
*   T100 (mensajes), CUS_IMGACT (actividades IMG), TNODEIMGT (nodos IMG)
* Export: filas cuyo ES falta o es igual al EN (copia del supplement).
* Import: actualiza la fila ES con el texto traducido.
* v6: P_MEM (oculto): datos en INDX(ZT) en vez de archivo del frontend,
*     para ejecucion en fondo desde el servicio HTTP ZCL_ZTRAD_HTTP
* v7: P_SRV (oculto): archivo en la PC/servidor bajo ztrad_rfc_files\
*     (OPEN DATASET), para lotes grandes sin pasar por HTTP
*----------------------------------------------------------------------*
DATA: gt_file  TYPE STANDARD TABLE OF string,
      gv_row   TYPE string,
      gv_tab   TYPE c,
      gv_key   TYPE string,
      gv_len   TYPE string,
      gv_cnt   TYPE i,
      gv_arbgb TYPE arbgb,
      gv_tcode TYPE tcode,
      gv_l     TYPE i.

DATA: lt_e100 TYPE STANDARD TABLE OF t100,
      lt_s100 TYPE STANDARD TABLE OF t100,
      ls_e100 TYPE t100,
      ls_s100 TYPE t100,
      lt_eact TYPE STANDARD TABLE OF cus_imgact,
      lt_sact TYPE STANDARD TABLE OF cus_imgact,
      ls_eact TYPE cus_imgact,
      ls_sact TYPE cus_imgact,
      lt_enod TYPE STANDARD TABLE OF tnodeimgt,
      lt_snod TYPE STANDARD TABLE OF tnodeimgt,
      ls_enod TYPE tnodeimgt,
      ls_snod TYPE tnodeimgt,
      lt_etc  TYPE STANDARD TABLE OF tstct,
      lt_stc  TYPE STANDARD TABLE OF tstct,
      ls_etc  TYPE tstct,
      ls_stc  TYPE tstct.

SELECT-OPTIONS s_cls FOR gv_arbgb.
SELECT-OPTIONS s_tcd FOR gv_tcode.
PARAMETERS: r_t100 RADIOBUTTON GROUP src DEFAULT 'X',
            r_act  RADIOBUTTON GROUP src,
            r_node RADIOBUTTON GROUP src,
            r_tstc RADIOBUTTON GROUP src,
            r_gen  RADIOBUTTON GROUP src.
* Fuente generica: tabla de textos, campo de texto y campo de idioma
PARAMETERS: p_gtab TYPE tabname,
            p_gfld TYPE fieldname,
            p_glng TYPE fieldname DEFAULT 'SPRAS'.
PARAMETERS: r_exp  RADIOBUTTON GROUP mod DEFAULT 'X',
            r_imp  RADIOBUTTON GROUP mod,
            p_test AS CHECKBOX DEFAULT 'X',
            p_file TYPE string LOWER CASE
                   DEFAULT 'C:\Users\user\Documents\ztrad_txt.txt'.
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
FORM add USING pv_src pv_key pv_len pv_en.
  CONCATENATE pv_src pv_key pv_len pv_en pv_en
    INTO gv_row SEPARATED BY gv_tab.
  APPEND gv_row TO gt_file.
  ADD 1 TO gv_cnt.
ENDFORM.

*----------------------------------------------------------------------*
FORM export.
  DATA lv_rc TYPE i.
  REFRESH gt_file.
  CONCATENATE 'SRC' 'KEY' 'MAXLEN' 'EN' 'ES' INTO gv_row SEPARATED BY gv_tab.
  APPEND gv_row TO gt_file.

  IF r_t100 = 'X'.
    SELECT * FROM t100 INTO TABLE lt_e100
      WHERE sprsl = 'E' AND arbgb IN s_cls.
    SELECT * FROM t100 INTO TABLE lt_s100
      WHERE sprsl = 'S' AND arbgb IN s_cls.
    SORT lt_s100 BY arbgb msgnr.
    DESCRIBE FIELD ls_e100-text LENGTH gv_l IN CHARACTER MODE.
    gv_len = gv_l. CONDENSE gv_len.
    LOOP AT lt_e100 INTO ls_e100.
      CHECK ls_e100-text IS NOT INITIAL.
      READ TABLE lt_s100 INTO ls_s100
        WITH KEY arbgb = ls_e100-arbgb msgnr = ls_e100-msgnr BINARY SEARCH.
      IF sy-subrc = 0 AND ls_s100-text <> ls_e100-text.
        CONTINUE.
      ENDIF.
      CONCATENATE ls_e100-arbgb '|' ls_e100-msgnr INTO gv_key.
      PERFORM add USING 'T100' gv_key gv_len ls_e100-text.
    ENDLOOP.

  ELSEIF r_act = 'X'.
    SELECT * FROM cus_imgact INTO TABLE lt_eact WHERE spras = 'E'.
    SELECT * FROM cus_imgact INTO TABLE lt_sact WHERE spras = 'S'.
    SORT lt_sact BY activity.
    DESCRIBE FIELD ls_eact-text LENGTH gv_l IN CHARACTER MODE.
    gv_len = gv_l. CONDENSE gv_len.
    LOOP AT lt_eact INTO ls_eact.
      CHECK ls_eact-text IS NOT INITIAL.
      READ TABLE lt_sact INTO ls_sact
        WITH KEY activity = ls_eact-activity BINARY SEARCH.
      IF sy-subrc = 0 AND ls_sact-text <> ls_eact-text.
        CONTINUE.
      ENDIF.
      gv_key = ls_eact-activity.
      PERFORM add USING 'IMGACT' gv_key gv_len ls_eact-text.
    ENDLOOP.

  ELSEIF r_gen = 'X'.
    PERFORM gen_export.

  ELSEIF r_tstc = 'X'.
    SELECT * FROM tstct INTO TABLE lt_etc
      WHERE sprsl = 'E' AND tcode IN s_tcd.
    SELECT * FROM tstct INTO TABLE lt_stc
      WHERE sprsl = 'S' AND tcode IN s_tcd.
    SORT lt_stc BY tcode.
    DESCRIBE FIELD ls_etc-ttext LENGTH gv_l IN CHARACTER MODE.
    gv_len = gv_l. CONDENSE gv_len.
    LOOP AT lt_etc INTO ls_etc.
      CHECK ls_etc-ttext IS NOT INITIAL.
      READ TABLE lt_stc INTO ls_stc
        WITH KEY tcode = ls_etc-tcode BINARY SEARCH.
      IF sy-subrc = 0 AND ls_stc-ttext <> ls_etc-ttext.
        CONTINUE.
      ENDIF.
      gv_key = ls_etc-tcode.
      PERFORM add USING 'TSTCT' gv_key gv_len ls_etc-ttext.
    ENDLOOP.

  ELSE.
    SELECT * FROM tnodeimgt INTO TABLE lt_enod WHERE spras = 'E'.
    SELECT * FROM tnodeimgt INTO TABLE lt_snod WHERE spras = 'S'.
    SORT lt_snod BY tree_id extension branch node_id ext_key.
    DESCRIBE FIELD ls_enod-text LENGTH gv_l IN CHARACTER MODE.
    gv_len = gv_l. CONDENSE gv_len.
    LOOP AT lt_enod INTO ls_enod.
      CHECK ls_enod-text IS NOT INITIAL.
      READ TABLE lt_snod INTO ls_snod
        WITH KEY tree_id = ls_enod-tree_id extension = ls_enod-extension
                 branch = ls_enod-branch node_id = ls_enod-node_id
                 ext_key = ls_enod-ext_key BINARY SEARCH.
      IF sy-subrc = 0 AND ls_snod-text <> ls_enod-text.
        CONTINUE.
      ENDIF.
      CONCATENATE ls_enod-tree_id ls_enod-extension ls_enod-branch
                  ls_enod-node_id ls_enod-ext_key
        INTO gv_key SEPARATED BY '|'.
      PERFORM add USING 'IMGNODE' gv_key gv_len ls_enod-text.
    ENDLOOP.
  ENDIF.

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
  IF lv_rc <> 0.
    WRITE: / 'Error al grabar el archivo', p_file.
  ELSE.
    WRITE: / 'Textos exportados:', gv_cnt.
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
  DATA: lv_all TYPE string,
        lv_src TYPE string,
        lv_ml  TYPE string,
        lv_en  TYPE string,
        lv_es  TYPE string,
        lv_k1  TYPE string,
        lv_k2  TYPE string,
        lv_k3  TYPE string,
        lv_k4  TYPE string,
        lv_k5  TYPE string,
        lv_max TYPE i,
        lv_ok  TYPE i,
        lv_err TYPE i,
        lv_len TYPE i.

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

  IF p_test = 'X'.
    WRITE: / '*** MODO TEST: no se graba nada ***'.
  ENDIF.

  LOOP AT gt_file INTO gv_row.
    IF sy-tabix = 1 OR gv_row IS INITIAL.
      CONTINUE.
    ENDIF.
    CLEAR: lv_src, gv_key, lv_ml, lv_en, lv_es.
    SPLIT gv_row AT gv_tab INTO lv_src gv_key lv_ml lv_en lv_es.
    IF lv_es IS INITIAL OR lv_es = lv_en.
      CONTINUE.
    ENDIF.
    lv_max = lv_ml.
    lv_len = strlen( lv_es ).
    IF lv_max > 0 AND lv_len > lv_max.
      WRITE: / 'Demasiado largo:', lv_src, gv_key, lv_len, lv_max.
      ADD 1 TO lv_err.
      CONTINUE.
    ENDIF.

    CASE lv_src.
      WHEN 'T100'.
        SPLIT gv_key AT '|' INTO lv_k1 lv_k2.
        CLEAR ls_s100.
        ls_s100-sprsl = 'S'.
        ls_s100-arbgb = lv_k1.
        ls_s100-msgnr = lv_k2.
        ls_s100-text  = lv_es.
        IF p_test IS INITIAL.
          MODIFY t100 FROM ls_s100.
        ENDIF.
      WHEN 'IMGACT'.
        CLEAR ls_sact.
        ls_sact-spras    = 'S'.
        ls_sact-activity = gv_key.
        ls_sact-text     = lv_es.
        IF p_test IS INITIAL.
          MODIFY cus_imgact FROM ls_sact.
        ENDIF.
      WHEN 'IMGNODE'.
        SPLIT gv_key AT '|' INTO lv_k1 lv_k2 lv_k3 lv_k4 lv_k5.
        CLEAR ls_snod.
        SELECT SINGLE * FROM tnodeimgt INTO ls_snod
          WHERE spras = 'E' AND tree_id = lv_k1 AND extension = lv_k2
            AND branch = lv_k3 AND node_id = lv_k4 AND ext_key = lv_k5.
        IF sy-subrc <> 0.
          ADD 1 TO lv_err.
          CONTINUE.
        ENDIF.
        ls_snod-spras = 'S'.
        ls_snod-text  = lv_es.
        IF p_test IS INITIAL.
          MODIFY tnodeimgt FROM ls_snod.
        ENDIF.
      WHEN 'TSTCT'.
        CLEAR ls_stc.
        ls_stc-sprsl = 'S'.
        ls_stc-tcode = gv_key.
        ls_stc-ttext = lv_es.
        IF p_test IS INITIAL.
          MODIFY tstct FROM ls_stc.
        ENDIF.
      WHEN OTHERS.
        IF lv_src = p_gtab AND p_gtab IS NOT INITIAL.
          PERFORM gen_import USING gv_key lv_es CHANGING lv_err lv_len.
          IF lv_len <> 0.
            CONTINUE.
          ENDIF.
        ELSE.
          ADD 1 TO lv_err.
          CONTINUE.
        ENDIF.
    ENDCASE.
    ADD 1 TO lv_ok.
  ENDLOOP.

  IF p_test IS INITIAL.
    COMMIT WORK.
  ENDIF.
  WRITE: / 'Textos OK:', lv_ok,
         / 'Textos con error:', lv_err.
ENDFORM.

*----------------------------------------------------------------------*
* Fuente generica
*----------------------------------------------------------------------*
FORM gen_keys CHANGING ct_keys TYPE string_table.
  DATA: lt_f TYPE STANDARD TABLE OF dd03l,
        ls_f TYPE dd03l.
  SELECT * FROM dd03l INTO TABLE lt_f
    WHERE tabname = p_gtab AND as4local = 'A' AND keyflag = 'X'
    ORDER BY position.
  REFRESH ct_keys.
  LOOP AT lt_f INTO ls_f.
    CHECK ls_f-fieldname(1) <> '.'.
    CHECK ls_f-datatype <> 'CLNT'.
    CHECK ls_f-fieldname <> p_glng.
    APPEND ls_f-fieldname TO ct_keys.
  ENDLOOP.
ENDFORM.

FORM gen_keystr USING is_row TYPE any it_keys TYPE string_table
                CHANGING cv_key TYPE string.
  DATA lv_f TYPE string.
  FIELD-SYMBOLS <f> TYPE any.
  CLEAR cv_key.
  LOOP AT it_keys INTO lv_f.
    ASSIGN COMPONENT lv_f OF STRUCTURE is_row TO <f>.
    IF sy-tabix = 1.
      cv_key = <f>.
    ELSE.
      CONCATENATE cv_key '|' <f> INTO cv_key.
    ENDIF.
  ENDLOOP.
ENDFORM.

FORM gen_export.
  TYPES: BEGIN OF ty_kv,
           k TYPE string,
           t TYPE string,
         END OF ty_kv.
  DATA: lt_keys TYPE string_table,
        lr_e    TYPE REF TO data,
        lr_s    TYPE REF TO data,
        lv_wh   TYPE string,
        lt_kv   TYPE SORTED TABLE OF ty_kv WITH UNIQUE KEY k,
        ls_kv   TYPE ty_kv,
        lv_txt  TYPE string.
  FIELD-SYMBOLS: <et> TYPE STANDARD TABLE,
                 <st> TYPE STANDARD TABLE,
                 <w>  TYPE any,
                 <t>  TYPE any.

  PERFORM gen_keys CHANGING lt_keys.
  CREATE DATA lr_e TYPE STANDARD TABLE OF (p_gtab).
  CREATE DATA lr_s TYPE STANDARD TABLE OF (p_gtab).
  ASSIGN lr_e->* TO <et>.
  ASSIGN lr_s->* TO <st>.
  CONCATENATE p_glng ` = 'E'` INTO lv_wh.
  SELECT * FROM (p_gtab) INTO TABLE <et> WHERE (lv_wh).
  CONCATENATE p_glng ` = 'S'` INTO lv_wh.
  SELECT * FROM (p_gtab) INTO TABLE <st> WHERE (lv_wh).

  LOOP AT <st> ASSIGNING <w>.
    PERFORM gen_keystr USING <w> lt_keys CHANGING ls_kv-k.
    ASSIGN COMPONENT p_gfld OF STRUCTURE <w> TO <t>.
    ls_kv-t = <t>.
    INSERT ls_kv INTO TABLE lt_kv.
  ENDLOOP.

  LOOP AT <et> ASSIGNING <w>.
    ASSIGN COMPONENT p_gfld OF STRUCTURE <w> TO <t>.
    IF sy-subrc <> 0.
      WRITE: / 'Campo de texto no existe:', p_gfld.
      RETURN.
    ENDIF.
    CHECK <t> IS NOT INITIAL.
    lv_txt = <t>.
    PERFORM gen_keystr USING <w> lt_keys CHANGING gv_key.
    READ TABLE lt_kv INTO ls_kv WITH TABLE KEY k = gv_key.
    IF sy-subrc = 0 AND ls_kv-t <> lv_txt.
      CONTINUE.
    ENDIF.
    DESCRIBE FIELD <t> LENGTH gv_l IN CHARACTER MODE.
    gv_len = gv_l. CONDENSE gv_len.
    PERFORM add USING p_gtab gv_key gv_len lv_txt.
  ENDLOOP.
ENDFORM.

FORM gen_import USING pv_key TYPE string pv_es TYPE string
                CHANGING cv_err TYPE i cv_skip TYPE i.
  DATA: lt_keys TYPE string_table,
        lt_val  TYPE string_table,
        lv_f    TYPE string,
        lv_v    TYPE string,
        lv_wh   TYPE string,
        lv_c    TYPE string,
        lr_w    TYPE REF TO data.
  FIELD-SYMBOLS: <w> TYPE any,
                 <f> TYPE any.

  cv_skip = 0.
  PERFORM gen_keys CHANGING lt_keys.
  SPLIT pv_key AT '|' INTO TABLE lt_val.
  CONCATENATE p_glng ` = 'E'` INTO lv_wh.
  LOOP AT lt_keys INTO lv_f.
    READ TABLE lt_val INTO lv_v INDEX sy-tabix.
    REPLACE ALL OCCURRENCES OF `'` IN lv_v WITH `''`.
    CONCATENATE lv_wh ` AND ` lv_f ` = '` lv_v `'` INTO lv_wh.
  ENDLOOP.
  CREATE DATA lr_w TYPE (p_gtab).
  ASSIGN lr_w->* TO <w>.
  SELECT SINGLE * FROM (p_gtab) INTO <w> WHERE (lv_wh).
  IF sy-subrc <> 0.
    WRITE: / 'Fila EN no encontrada:', pv_key(60).
    ADD 1 TO cv_err.
    cv_skip = 1.
    RETURN.
  ENDIF.
* Si ya existe la fila ES, se parte de ella (no pisar otros campos)
  REPLACE FIRST OCCURRENCE OF `= 'E'` IN lv_wh WITH `= 'S'`.
  SELECT SINGLE * FROM (p_gtab) INTO <w> WHERE (lv_wh).
  ASSIGN COMPONENT p_glng OF STRUCTURE <w> TO <f>.
  <f> = 'S'.
  ASSIGN COMPONENT p_gfld OF STRUCTURE <w> TO <f>.
  <f> = pv_es.
  IF p_test IS INITIAL.
    MODIFY (p_gtab) FROM <w>.
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
