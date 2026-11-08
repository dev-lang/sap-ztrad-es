REPORT ztrad_tabdump.
*----------------------------------------------------------------------*
* Volcado generico de una tabla a archivo TSV (UTF-8) en el PC.
* _final: P_SRV/P_MEM (ocultos) para correr en fondo por ZCL_ZTRAD_HTTP
*----------------------------------------------------------------------*
PARAMETERS: p_tab   TYPE tabname OBLIGATORY,
            p_where TYPE c LENGTH 200 LOWER CASE,
            p_file  TYPE string LOWER CASE
                    DEFAULT 'C:\Users\user\Documents\ztrad_dump.txt'.
PARAMETERS p_mem TYPE indx-srtfd NO-DISPLAY.
PARAMETERS p_srv TYPE char45 LOWER CASE NO-DISPLAY.
CONSTANTS c_base TYPE string VALUE 'C:\Users\user\Documents\ztrad_rfc_files\'.

DATA gt_file TYPE STANDARD TABLE OF string.

START-OF-SELECTION.
  DATA: lr_t    TYPE REF TO data,
        lo_sd   TYPE REF TO cl_abap_structdescr,
        lt_comp TYPE abap_compdescr_tab,
        ls_comp TYPE abap_compdescr,
        lv_rc   TYPE i,
        lv_row  TYPE string,
        lv_v    TYPE string,
        lv_tab  TYPE c,
        lv_n    TYPE i.
  FIELD-SYMBOLS: <t> TYPE STANDARD TABLE,
                 <w> TYPE any,
                 <f> TYPE any.

  lv_tab = cl_abap_char_utilities=>horizontal_tab.
  CREATE DATA lr_t TYPE STANDARD TABLE OF (p_tab).
  ASSIGN lr_t->* TO <t>.
  IF p_where IS INITIAL.
    SELECT * FROM (p_tab) INTO TABLE <t>.
  ELSE.
    SELECT * FROM (p_tab) INTO TABLE <t> WHERE (p_where).
  ENDIF.

  lo_sd ?= cl_abap_typedescr=>describe_by_name( p_tab ).
  lt_comp = lo_sd->components.
  CLEAR lv_row.
  LOOP AT lt_comp INTO ls_comp.
    IF sy-tabix > 1.
      CONCATENATE lv_row lv_tab INTO lv_row.
    ENDIF.
    CONCATENATE lv_row ls_comp-name INTO lv_row.
  ENDLOOP.
  APPEND lv_row TO gt_file.

  LOOP AT <t> ASSIGNING <w>.
    CLEAR lv_row.
    LOOP AT lt_comp INTO ls_comp.
      ASSIGN COMPONENT sy-tabix OF STRUCTURE <w> TO <f>.
      lv_v = <f>.
      IF sy-tabix > 1.
        CONCATENATE lv_row lv_tab lv_v INTO lv_row.
      ELSE.
        lv_row = lv_v.
      ENDIF.
    ENDLOOP.
    APPEND lv_row TO gt_file.
    ADD 1 TO lv_n.
  ENDLOOP.

  PERFORM file_write CHANGING lv_rc.
  WRITE: / 'Filas:', lv_n.

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
