REPORT ztrad_doku.
*----------------------------------------------------------------------*
* Traduccion EN -> ES de documentacion SE61/DOKU (ayuda F1).
* Por defecto ID 'DE' (elementos de datos, F1 de FD03 y demas).
* Export: documentos EN de S_OBJ que no tienen version ES.
* Archivo: ID OBJECT LINE FORMAT EN ES  (una fila por linea TLINE)
* Import: por ID+OBJECT arma las lineas con FORMAT + ES (en el orden
*   de LINE) y graba con DOCU_UPDATE en idioma S. Se pueden agregar
*   o quitar lineas: cuenta solo el orden. ES vacio = linea vacia.
*   Una fila con ES = '#DEL' se descarta.
* _final: P_SRV/P_MEM (ocultos) para correr en fondo por ZCL_ZTRAD_HTTP
*----------------------------------------------------------------------*
DATA: gt_file TYPE STANDARD TABLE OF string,
      gv_row  TYPE string,
      gv_tab  TYPE c,
      gv_obj  TYPE dokhl-object.

SELECT-OPTIONS s_obj FOR gv_obj NO INTERVALS.
PARAMETERS: p_id   TYPE dokhl-id DEFAULT 'DE',
            r_exp  RADIOBUTTON GROUP mod DEFAULT 'X',
            r_imp  RADIOBUTTON GROUP mod,
            p_test AS CHECKBOX DEFAULT 'X',
            p_all  AS CHECKBOX,
            p_file TYPE string LOWER CASE
                   DEFAULT 'C:\Users\user\Documents\ztrad_doku.txt'.
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
FORM export.
  TYPES: BEGIN OF ty_o,
           object TYPE dokhl-object,
         END OF ty_o.
  DATA: lt_o    TYPE SORTED TABLE OF ty_o WITH UNIQUE KEY object,
        ls_o    TYPE ty_o,
        lt_s    TYPE SORTED TABLE OF ty_o WITH UNIQUE KEY object,
        lt_line TYPE STANDARD TABLE OF tline,
        ls_line TYPE tline,
        ls_head TYPE thead,
        lv_n    TYPE n LENGTH 4,
        lv_txt  TYPE string,
        lv_docs TYPE i,
        lv_cnt  TYPE i,
        lv_rc   TYPE i.

  CONCATENATE 'ID' 'OBJECT' 'LINE' 'FORMAT' 'EN' 'ES' INTO gv_row
    SEPARATED BY gv_tab.
  APPEND gv_row TO gt_file.

  SELECT DISTINCT object FROM dokil INTO TABLE lt_o
    WHERE id = p_id AND object IN s_obj AND langu = 'E' AND typ = 'E'.
  IF p_all IS INITIAL.
    SELECT DISTINCT object FROM dokil INTO TABLE lt_s
      WHERE id = p_id AND object IN s_obj AND langu = 'S' AND typ = 'E'.
  ENDIF.

  LOOP AT lt_o INTO ls_o.
    READ TABLE lt_s WITH TABLE KEY object = ls_o-object
      TRANSPORTING NO FIELDS.
    CHECK sy-subrc <> 0.
    REFRESH lt_line.
    CALL FUNCTION 'DOCU_GET'
      EXPORTING
        id     = p_id
        langu  = 'E'
        object = ls_o-object
        typ    = 'E'
      IMPORTING
        head   = ls_head
      TABLES
        line   = lt_line
      EXCEPTIONS
        OTHERS = 1.
    CHECK sy-subrc = 0 AND lt_line IS NOT INITIAL.
    ADD 1 TO lv_docs.
    CLEAR lv_n.
    LOOP AT lt_line INTO ls_line.
      ADD 1 TO lv_n.
      lv_txt = ls_line-tdline.
      REPLACE ALL OCCURRENCES OF gv_tab IN lv_txt WITH ` `.
      CONCATENATE p_id ls_o-object lv_n ls_line-tdformat lv_txt lv_txt
        INTO gv_row SEPARATED BY gv_tab.
      APPEND gv_row TO gt_file.
      ADD 1 TO lv_cnt.
    ENDLOOP.
  ENDLOOP.

  PERFORM file_write CHANGING lv_rc.
  IF lv_rc = 0.
    WRITE: / 'Documentos exportados:', lv_docs,
           / 'Lineas exportadas:', lv_cnt.
  ENDIF.
ENDFORM.

*----------------------------------------------------------------------*
FORM import.
  DATA: lv_id   TYPE string,
        lv_obj  TYPE string,
        lv_lno  TYPE string,
        lv_fmt  TYPE string,
        lv_en   TYPE string,
        lv_es   TYPE string,
        lv_key  TYPE string,
        lv_pkey TYPE string,
        lv_len  TYPE i,
        lv_bad  TYPE c,
        lv_ok   TYPE i,
        lv_lin  TYPE i,
        lv_err  TYPE i,
        ls_line TYPE tline,
        lt_line TYPE STANDARD TABLE OF tline.

  PERFORM file_read CHANGING lv_err.
  IF lv_err <> 0.
    RETURN.
  ENDIF.
  SORT gt_file.  "ID+OBJECT+LINE (LINE con ceros a la izquierda)

  LOOP AT gt_file INTO gv_row.
    CHECK gv_row IS NOT INITIAL.
    CLEAR: lv_id, lv_obj, lv_lno, lv_fmt, lv_en, lv_es.
    SPLIT gv_row AT gv_tab INTO lv_id lv_obj lv_lno lv_fmt lv_en lv_es.
    CHECK lv_id <> 'ID'.
    CONCATENATE lv_id lv_obj INTO lv_key SEPARATED BY gv_tab.
    IF lv_key <> lv_pkey.
      IF lv_pkey IS NOT INITIAL.
        PERFORM save_doc USING lv_pkey lt_line lv_bad
                         CHANGING lv_ok lv_err.
      ENDIF.
      REFRESH lt_line.
      CLEAR lv_bad.
      lv_pkey = lv_key.
    ENDIF.
    CHECK lv_es <> '#DEL'.
    lv_len = strlen( lv_es ).
    IF lv_len > 132.
      WRITE: / 'Linea demasiado larga:', lv_id, lv_obj, lv_lno, lv_len.
      lv_bad = 'X'.
    ENDIF.
    CLEAR ls_line.
    ls_line-tdformat = lv_fmt.
    ls_line-tdline   = lv_es.
    APPEND ls_line TO lt_line.
    ADD 1 TO lv_lin.
  ENDLOOP.
  IF lv_pkey IS NOT INITIAL.
    PERFORM save_doc USING lv_pkey lt_line lv_bad
                     CHANGING lv_ok lv_err.
  ENDIF.

  IF p_test IS INITIAL.
    COMMIT WORK.
  ENDIF.
  WRITE: / 'Documentos actualizados:', lv_ok,
         / 'Lineas leidas:', lv_lin,
         / 'Errores:', lv_err.
  IF p_test = 'X'.
    WRITE: / '(modo prueba, no se grabo nada)'.
  ENDIF.
ENDFORM.

FORM save_doc USING pv_key  TYPE string
                    pt_line TYPE STANDARD TABLE
                    pv_bad  TYPE c
              CHANGING cv_ok  TYPE i
                       cv_err TYPE i.
  DATA: lv_id   TYPE dokhl-id,
        lv_obj  TYPE dokhl-object,
        lv_s1   TYPE string,
        lv_s2   TYPE string,
        ls_head TYPE thead,
        lt_en   TYPE STANDARD TABLE OF tline,
        lv_ver  TYPE dokhl-dokversion.

  IF pv_bad = 'X'.
    ADD 1 TO cv_err.
    RETURN.
  ENDIF.
  SPLIT pv_key AT gv_tab INTO lv_s1 lv_s2.
  lv_id  = lv_s1.
  lv_obj = lv_s2.

* Cabecera tomada del documento EN (mismo TDNAME/TDID), idioma S
  CALL FUNCTION 'DOCU_GET'
    EXPORTING
      id     = lv_id
      langu  = 'E'
      object = lv_obj
      typ    = 'E'
    IMPORTING
      head   = ls_head
    TABLES
      line   = lt_en
    EXCEPTIONS
      OTHERS = 1.
  IF sy-subrc <> 0.
    WRITE: / 'Documento EN no encontrado:', lv_id, lv_obj.
    ADD 1 TO cv_err.
    RETURN.
  ENDIF.
  ls_head-tdspras = 'S'.

* Version ES: la ultima existente, o 1 si no hay
  SELECT MAX( dokversion ) FROM dokhl INTO lv_ver
    WHERE id = lv_id AND object = lv_obj AND langu = 'S' AND typ = 'E'.
  IF lv_ver IS INITIAL.
    lv_ver = 1.
  ENDIF.
  ls_head-tdversion = lv_ver.

  IF p_test IS INITIAL.
    CALL FUNCTION 'DOCU_UPDATE'
      EXPORTING
        head    = ls_head
        state   = 'A'
        typ     = 'E'
        version = lv_ver
      TABLES
        line    = pt_line
      EXCEPTIONS
        OTHERS  = 1.
    IF sy-subrc <> 0.
      WRITE: / 'Error DOCU_UPDATE:', lv_id, lv_obj, sy-subrc.
      ADD 1 TO cv_err.
      RETURN.
    ENDIF.
  ENDIF.
  ADD 1 TO cv_ok.
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
