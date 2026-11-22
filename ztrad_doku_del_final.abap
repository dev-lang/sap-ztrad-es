REPORT ztrad_doku_del.
*----------------------------------------------------------------------*
* Reversion de la ayuda F1 traducida: borra SOLO la version ES
* (idioma S) de los documentos DOKU listados en el archivo.
* Archivo (TSV, UTF-8 con BOM, CRLF): ID <tab> OBJECT  (1a fila = titulo)
*
* v2 (22/11/2026): ya NO usa DOCU_DEL. DOCU_DEL borra el documento en
*   TODOS los idiomas aunque se le pase LANGU = 'S' (v1 borro asi la
*   version EN y DE de 26.613 documentos). Ahora borra directamente las
*   filas de DOKHL, DOKIL y DOKTL con LANGU = 'S', y controla antes y
*   despues que las filas de los demas idiomas no cambien; si cambian,
*   hace ROLLBACK de ese documento y lo informa como error.
* P_TEST = X: solo cuenta, no borra nada.
* P_SRV (oculto): ruta relativa a C:\Users\user\Documents\ztrad_rfc_files\
*----------------------------------------------------------------------*
DATA: gt_file TYPE STANDARD TABLE OF string,
      gv_row  TYPE string,
      gv_tab  TYPE c.

PARAMETERS: p_test AS CHECKBOX DEFAULT 'X',
            p_file TYPE string LOWER CASE
                   DEFAULT 'C:\Users\user\Documents\ztrad_doku_del.txt'.
PARAMETERS p_srv TYPE char45 LOWER CASE NO-DISPLAY.
CONSTANTS c_base TYPE string VALUE 'C:\Users\user\Documents\ztrad_rfc_files\'.

START-OF-SELECTION.
  gv_tab = cl_abap_char_utilities=>horizontal_tab.
  PERFORM run.

FORM count_other USING pv_id  TYPE dokhl-id
                       pv_obj TYPE dokhl-object
                 CHANGING cv_n TYPE i.
  DATA lv_c TYPE i.
  CLEAR cv_n.
  SELECT COUNT(*) FROM dokhl INTO lv_c
    WHERE id = pv_id AND object = pv_obj AND langu <> 'S'.
  cv_n = cv_n + lv_c.
  SELECT COUNT(*) FROM dokil INTO lv_c
    WHERE id = pv_id AND object = pv_obj AND langu <> 'S'.
  cv_n = cv_n + lv_c.
  SELECT COUNT(*) FROM doktl INTO lv_c
    WHERE id = pv_id AND object = pv_obj AND langu <> 'S'.
  cv_n = cv_n + lv_c.
ENDFORM.

FORM run.
  DATA: lv_rc   TYPE i,
        lv_s1   TYPE string,
        lv_s2   TYPE string,
        lv_id   TYPE dokhl-id,
        lv_obj  TYPE dokhl-object,
        lv_hl   TYPE i,
        lv_il   TYPE i,
        lv_tl   TYPE i,
        lv_oth1 TYPE i,
        lv_oth2 TYPE i,
        lv_ok   TYPE i,
        lv_none TYPE i,
        lv_err  TYPE i,
        lv_n    TYPE i,
        lv_rhl  TYPE i,
        lv_ril  TYPE i,
        lv_rtl  TYPE i.

  PERFORM file_read CHANGING lv_rc.
  IF lv_rc <> 0.
    RETURN.
  ENDIF.
  IF p_test = 'X'.
    WRITE: / '*** MODO TEST: no se borra nada ***'.
  ENDIF.

  LOOP AT gt_file INTO gv_row.
    CHECK gv_row IS NOT INITIAL.
    CLEAR: lv_s1, lv_s2.
    SPLIT gv_row AT gv_tab INTO lv_s1 lv_s2.
    CHECK lv_s1 <> 'ID'.
    lv_id  = lv_s1.
    lv_obj = lv_s2.
    ADD 1 TO lv_n.

    SELECT COUNT(*) FROM dokhl INTO lv_hl
      WHERE id = lv_id AND object = lv_obj AND langu = 'S'.
    SELECT COUNT(*) FROM dokil INTO lv_il
      WHERE id = lv_id AND object = lv_obj AND langu = 'S'.
    SELECT COUNT(*) FROM doktl INTO lv_tl
      WHERE id = lv_id AND object = lv_obj AND langu = 'S'.
    IF lv_hl = 0 AND lv_il = 0 AND lv_tl = 0.
      ADD 1 TO lv_none.
      CONTINUE.
    ENDIF.

    PERFORM count_other USING lv_id lv_obj CHANGING lv_oth1.

    IF p_test IS INITIAL.
      DELETE FROM doktl WHERE id = lv_id AND object = lv_obj AND langu = 'S'.
      DELETE FROM dokil WHERE id = lv_id AND object = lv_obj AND langu = 'S'.
      DELETE FROM dokhl WHERE id = lv_id AND object = lv_obj AND langu = 'S'.
      PERFORM count_other USING lv_id lv_obj CHANGING lv_oth2.
      IF lv_oth2 <> lv_oth1.
        ROLLBACK WORK.
        WRITE: / 'ERROR: cambiaron otros idiomas, se deshizo:', lv_id, lv_obj.
        ADD 1 TO lv_err.
        CONTINUE.
      ENDIF.
      COMMIT WORK.
    ENDIF.
    ADD 1 TO lv_ok.
    lv_rhl = lv_rhl + lv_hl.
    lv_ril = lv_ril + lv_il.
    lv_rtl = lv_rtl + lv_tl.
  ENDLOOP.

  WRITE: / 'Documentos leidos:', lv_n,
         / 'Documentos con version ES borrada:', lv_ok,
         / '  filas DOKHL/DOKIL/DOKTL (S):', lv_rhl, lv_ril, lv_rtl,
         / 'Sin version ES (nada que borrar):', lv_none,
         / 'Errores:', lv_err.
  IF p_test = 'X'.
    WRITE: / '(modo prueba: "borrada" = lo que se borraria)'.
  ENDIF.
ENDFORM.

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
