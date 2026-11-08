REPORT ztrad_tpool LINE-SIZE 255.
*----------------------------------------------------------------------*
* Traduccion EN -> ES de pools de textos de programas leyendo
* directamente READ/INSERT TEXTPOOL (para programas que LXE no cubre,
* p.ej. bases de datos logicas SAPDB*).
* Archivo: SRC(programa) KEY(id|clave) MAXLEN EN ES
* _final: P_SRV/P_MEM (ocultos) para correr en fondo por ZCL_ZTRAD_HTTP
*----------------------------------------------------------------------*
DATA: gt_file TYPE STANDARD TABLE OF string,
      gv_row  TYPE string,
      gv_tab  TYPE c,
      gv_prog TYPE progname,
      gv_tcod TYPE tstc-tcode.

SELECT-OPTIONS: s_prog FOR gv_prog NO INTERVALS,
                s_tcod FOR gv_tcod NO INTERVALS.
PARAMETERS: r_exp  RADIOBUTTON GROUP mod DEFAULT 'X',
            r_imp  RADIOBUTTON GROUP mod,
            p_test AS CHECKBOX DEFAULT 'X',
            p_file TYPE string LOWER CASE
                   DEFAULT 'C:\Users\user\Documents\ztrad_tpool.txt'.
PARAMETERS p_mem TYPE indx-srtfd NO-DISPLAY.
PARAMETERS p_srv TYPE char45 LOWER CASE NO-DISPLAY.
CONSTANTS c_base TYPE string VALUE 'C:\Users\user\Documents\ztrad_rfc_files\'.

START-OF-SELECTION.
  gv_tab = cl_abap_char_utilities=>horizontal_tab.
  IF s_tcod[] IS NOT INITIAL.
    PERFORM add_tcode_programs.
  ENDIF.
  IF r_exp = 'X'.
    PERFORM export.
  ELSE.
    PERFORM import.
  ENDIF.

FORM add_tcode_programs.
  TYPES: BEGIN OF ty_t,
           tcode TYPE tstc-tcode,
           pgmna TYPE tstc-pgmna,
         END OF ty_t.
  DATA: lt_t     TYPE STANDARD TABLE OF ty_t,
        ls_t     TYPE ty_t,
        lv_param TYPE tstcp-param,
        lv_rep   TYPE string,
        lv_rest  TYPE string,
        lt_p     TYPE STANDARD TABLE OF progname,
        lv_p     TYPE progname,
        lv_n     TYPE i.
  SELECT tcode pgmna FROM tstc INTO TABLE lt_t WHERE tcode IN s_tcod.
  LOOP AT lt_t INTO ls_t.
    IF ls_t-pgmna IS NOT INITIAL.
      APPEND ls_t-pgmna TO lt_p.
    ENDIF.
    CLEAR lv_param.
    SELECT SINGLE param FROM tstcp INTO lv_param WHERE tcode = ls_t-tcode.
    IF lv_param CS 'REPORT='.
      lv_rest = lv_param+sy-fdpos.
      SHIFT lv_rest BY 7 PLACES.
      SPLIT lv_rest AT ';' INTO lv_rep lv_rest.
      CONDENSE lv_rep.
      IF lv_rep IS NOT INITIAL.
        lv_p = lv_rep.
        APPEND lv_p TO lt_p.
      ENDIF.
    ENDIF.
  ENDLOOP.
  SORT lt_p.
  DELETE ADJACENT DUPLICATES FROM lt_p.
  LOOP AT lt_p INTO lv_p.
    SELECT SINGLE name FROM trdir INTO lv_p WHERE name = lv_p.
    CHECK sy-subrc = 0.
    s_prog-sign = 'I'. s_prog-option = 'EQ'. s_prog-low = lv_p.
    APPEND s_prog.
    ADD 1 TO lv_n.
  ENDLOOP.
  SORT s_prog BY low.
  DELETE ADJACENT DUPLICATES FROM s_prog COMPARING low.
  WRITE: / 'Programas a partir de transacciones:', lv_n.
ENDFORM.

FORM export.
  DATA: lt_e   TYPE STANDARD TABLE OF textpool,
        lt_s   TYPE STANDARD TABLE OF textpool,
        ls_e   TYPE textpool,
        ls_s   TYPE textpool,
        lv_key TYPE string,
        lv_len TYPE string,
        lv_txt TYPE string,
        lv_cnt TYPE i.

  CONCATENATE 'SRC' 'KEY' 'MAXLEN' 'EN' 'ES' INTO gv_row SEPARATED BY gv_tab.
  APPEND gv_row TO gt_file.
  LOOP AT s_prog.
    gv_prog = s_prog-low.
    READ TEXTPOOL gv_prog INTO lt_e LANGUAGE 'E'.
    READ TEXTPOOL gv_prog INTO lt_s LANGUAGE 'S'.
    SORT lt_s BY id key.
    LOOP AT lt_e INTO ls_e.
      CHECK ls_e-id <> 'R' OR ls_e-entry IS NOT INITIAL.
      CHECK ls_e-entry IS NOT INITIAL.
      lv_txt = ls_e-entry.
      IF ls_e-id = 'S'.
*       Textos de seleccion: los primeros 8 caracteres son relleno
        lv_txt = ls_e-entry+8.
        IF ls_e-entry(1) = 'D'.
          CONTINUE.            "referenciado al diccionario
        ENDIF.
      ENDIF.
      CHECK lv_txt IS NOT INITIAL.
      READ TABLE lt_s INTO ls_s WITH KEY id = ls_e-id key = ls_e-key
        BINARY SEARCH.
      IF sy-subrc = 0 AND ls_s-entry <> ls_e-entry AND ls_s-entry IS NOT INITIAL.
        CONTINUE.
      ENDIF.
      CONCATENATE ls_e-id '|' ls_e-key INTO lv_key.
      lv_len = ls_e-length.
      IF ls_e-id = 'S'.
        lv_len = ls_e-length - 8.
      ENDIF.
      CONDENSE lv_len.
      CONCATENATE gv_prog lv_key lv_len lv_txt lv_txt
        INTO gv_row SEPARATED BY gv_tab.
      APPEND gv_row TO gt_file.
      ADD 1 TO lv_cnt.
    ENDLOOP.
  ENDLOOP.

  DATA lv_rc TYPE i.
  PERFORM file_write CHANGING lv_rc.
  WRITE: / 'Textos exportados:', lv_cnt.
ENDFORM.

FORM import.
  TYPES: BEGIN OF ty_upd,
           prog TYPE progname,
           id   TYPE textpool-id,
           key  TYPE textpool-key,
           es   TYPE string,
         END OF ty_upd.
  DATA: lv_all  TYPE string,
        lv_src  TYPE string,
        lv_key  TYPE string,
        lv_ml   TYPE string,
        lv_en   TYPE string,
        lv_es   TYPE string,
        lv_id   TYPE string,
        lv_k    TYPE string,
        lt_upd  TYPE STANDARD TABLE OF ty_upd,
        ls_upd  TYPE ty_upd,
        lt_e    TYPE STANDARD TABLE OF textpool,
        lt_s    TYPE STANDARD TABLE OF textpool,
        ls_e    TYPE textpool,
        ls_s    TYPE textpool,
        lv_ok   TYPE i,
        lv_prev TYPE progname.
  FIELD-SYMBOLS <s> TYPE textpool.

  DATA lv_rc TYPE i.
  PERFORM file_read CHANGING lv_rc.
  IF lv_rc <> 0.
    RETURN.
  ENDIF.
  LOOP AT gt_file INTO gv_row.
    IF sy-tabix > 1.
      CONCATENATE lv_all cl_abap_char_utilities=>newline INTO lv_all.
    ENDIF.
    CONCATENATE lv_all gv_row INTO lv_all.
  ENDLOOP.
  REPLACE ALL OCCURRENCES OF cl_abap_char_utilities=>cr_lf
    IN lv_all WITH cl_abap_char_utilities=>newline.
  SPLIT lv_all AT cl_abap_char_utilities=>newline INTO TABLE gt_file.

  LOOP AT gt_file INTO gv_row.
    CHECK sy-tabix > 1 AND gv_row IS NOT INITIAL.
    SPLIT gv_row AT gv_tab INTO lv_src lv_key lv_ml lv_en lv_es.
    CHECK lv_es IS NOT INITIAL AND lv_es <> lv_en.
    SPLIT lv_key AT '|' INTO lv_id lv_k.
    ls_upd-prog = lv_src.
    ls_upd-id   = lv_id.
    ls_upd-key  = lv_k.
    ls_upd-es   = lv_es.
    APPEND ls_upd TO lt_upd.
  ENDLOOP.
  SORT lt_upd BY prog.

  LOOP AT lt_upd INTO ls_upd.
    IF ls_upd-prog <> lv_prev.
      IF lv_prev IS NOT INITIAL AND p_test IS INITIAL.
        INSERT TEXTPOOL lv_prev FROM lt_s LANGUAGE 'S'.
      ENDIF.
      lv_prev = ls_upd-prog.
      READ TEXTPOOL lv_prev INTO lt_e LANGUAGE 'E'.
      READ TEXTPOOL lv_prev INTO lt_s LANGUAGE 'S'.
*     Completar ES con las entradas EN que falten
      LOOP AT lt_e INTO ls_e.
        READ TABLE lt_s TRANSPORTING NO FIELDS
          WITH KEY id = ls_e-id key = ls_e-key.
        IF sy-subrc <> 0.
          APPEND ls_e TO lt_s.
        ENDIF.
      ENDLOOP.
    ENDIF.
    READ TABLE lt_s ASSIGNING <s> WITH KEY id = ls_upd-id key = ls_upd-key.
    CHECK sy-subrc = 0.
    IF ls_upd-id = 'S'.
      <s>-entry+8 = ls_upd-es.
    ELSE.
      <s>-entry = ls_upd-es.
    ENDIF.
    ADD 1 TO lv_ok.
    IF p_test = 'X'.
      WRITE: / ls_upd-prog, ls_upd-id, ls_upd-key, ls_upd-es(60).
    ENDIF.
  ENDLOOP.
  IF lv_prev IS NOT INITIAL AND p_test IS INITIAL.
    INSERT TEXTPOOL lv_prev FROM lt_s LANGUAGE 'S'.
    COMMIT WORK.
  ENDIF.
  WRITE: / 'Textos actualizados:', lv_ok.
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
