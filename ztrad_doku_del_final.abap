REPORT ztrad_doku_del.
*----------------------------------------------------------------------*
* Reversion de la ayuda F1 traducida: borra la version ES (idioma S)
* de los documentos DOKU listados en el archivo.
* Archivo (TSV, UTF-8 con BOM, CRLF): ID <tab> OBJECT  (1a fila = titulo)
* Solo toca idioma S. No toca la version EN ni otros idiomas.
* P_TEST = X: solo cuenta cuantos documentos S existen, no borra nada.
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

FORM run.
  DATA: lv_rc   TYPE i,
        lv_s1   TYPE string,
        lv_s2   TYPE string,
        lv_id   TYPE dokhl-id,
        lv_obj  TYPE dokhl-object,
        lv_cnt  TYPE i,
        lv_ok   TYPE i,
        lv_none TYPE i,
        lv_err  TYPE i,
        lv_n    TYPE i.

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

    SELECT COUNT(*) FROM dokhl INTO lv_cnt
      WHERE id = lv_id AND object = lv_obj AND langu = 'S'.
    IF lv_cnt = 0.
      ADD 1 TO lv_none.
      CONTINUE.
    ENDIF.

    IF p_test IS INITIAL.
      CALL FUNCTION 'DOCU_DEL'
        EXPORTING
          id     = lv_id
          langu  = 'S'
          object = lv_obj
          typ    = 'E'
        EXCEPTIONS
          OTHERS = 1.
      IF sy-subrc <> 0.
        WRITE: / 'Error DOCU_DEL:', lv_id, lv_obj, sy-subrc.
        ADD 1 TO lv_err.
        CONTINUE.
      ENDIF.
      IF lv_ok MOD 1000 = 999.
        COMMIT WORK.
      ENDIF.
    ENDIF.
    ADD 1 TO lv_ok.
  ENDLOOP.

  IF p_test IS INITIAL.
    COMMIT WORK.
  ENDIF.
  WRITE: / 'Documentos leidos:', lv_n,
         / 'Documentos ES borrados:', lv_ok,
         / 'Sin version ES (nada que borrar):', lv_none,
         / 'Errores:', lv_err.
  IF p_test = 'X'.
    WRITE: / '(modo prueba: "borrados" = los que se borrarian)'.
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
