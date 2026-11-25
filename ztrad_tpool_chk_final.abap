REPORT ztrad_tpool_chk LINE-SIZE 255.
*----------------------------------------------------------------------*
* SOLO LECTURA. Control de pools de textos despues de la reversion:
* para cada programa de la lista lee READ TEXTPOOL en S y en E y
* compara entrada por entrada (ID + KEY). No escribe nada en SAP.
*
* Entrada  P_SRV: lista de programas, uno por linea (ruta relativa a
*                 C:\Users\user\Documents\ztrad_rfc_files\)
* Salida   P_OUT: archivo TSV con las diferencias (misma carpeta base)
*   PROG  ID  KEY  ESTADO  TEXTO_S  TEXTO_E
*   ESTADO: DIF     = S y E distintos
*           S_SIN_E = hay entrada S y no E
*           PROG    = linea resumen del programa (S, E, iguales, dif)
* El listado (spool) solo muestra totales, para no inflar el spool.
* Para correr por ZCL_ZTRAD_HTTP en fondo:
*   prog=ZTRAD_TPOOL_CHK&p_srv=rfcimport\tpool_progs.txt
*                       &p_out=rfcexport\tpool_chk.txt
*----------------------------------------------------------------------*
TYPES: BEGIN OF ty_tp,
         id    TYPE textpool-id,
         key   TYPE textpool-key,
         entry TYPE textpool-entry,
       END OF ty_tp.

DATA: gt_list TYPE STANDARD TABLE OF string,
      gt_out  TYPE STANDARD TABLE OF string,
      gv_tab  TYPE c.

PARAMETERS: p_srv TYPE char45 LOWER CASE OBLIGATORY,
            p_out TYPE char45 LOWER CASE OBLIGATORY.
PARAMETERS p_mem TYPE indx-srtfd NO-DISPLAY.
CONSTANTS c_base TYPE string VALUE 'C:\Users\user\Documents\ztrad_rfc_files\'.

START-OF-SELECTION.
  gv_tab = cl_abap_char_utilities=>horizontal_tab.
  PERFORM run.

FORM path USING iv_rel TYPE char45 CHANGING cv_path TYPE string cv_rc TYPE i.
  cv_rc = 0.
  IF iv_rel CS '..' OR iv_rel CS ':' OR iv_rel(1) = '\' OR iv_rel(1) = '/'.
    WRITE: / 'Ruta no permitida:', iv_rel.
    cv_rc = 1.
    RETURN.
  ENDIF.
  CONCATENATE c_base iv_rel INTO cv_path.
ENDFORM.

FORM run.
  DATA: lv_in    TYPE string,
        lv_outp  TYPE string,
        lv_line  TYPE string,
        lv_rc    TYPE i,
        lv_prog  TYPE progname,
        lt_s     TYPE STANDARD TABLE OF textpool,
        lt_e     TYPE STANDARD TABLE OF textpool,
        ls_s     TYPE textpool,
        ls_e     TYPE textpool,
        lv_ns    TYPE i,
        lv_ne    TYPE i,
        lv_eq    TYPE i,
        lv_dif   TYPE i,
        lv_noe   TYPE i,
        lv_c1    TYPE string,
        lv_c2    TYPE string,
        lv_c3    TYPE string,
        lv_c4    TYPE string,
        lv_c5    TYPE string,
        lv_progs TYPE i,
        lv_nopl  TYPE i,
        lv_tns   TYPE i,
        lv_tne   TYPE i,
        lv_teq   TYPE i,
        lv_tdif  TYPE i,
        lv_tnoe  TYPE i,
        lv_pdif  TYPE i.

  PERFORM path USING p_srv CHANGING lv_in lv_rc.
  IF lv_rc <> 0. RETURN. ENDIF.
  PERFORM path USING p_out CHANGING lv_outp lv_rc.
  IF lv_rc <> 0. RETURN. ENDIF.

  OPEN DATASET lv_in FOR INPUT IN TEXT MODE ENCODING UTF-8
    SKIPPING BYTE-ORDER MARK WITH WINDOWS LINEFEED.
  IF sy-subrc <> 0.
    WRITE: / 'No se pudo abrir', lv_in.
    RETURN.
  ENDIF.
  DO.
    READ DATASET lv_in INTO lv_line.
    IF sy-subrc <> 0. EXIT. ENDIF.
    CONDENSE lv_line.
    IF lv_line IS NOT INITIAL.
      APPEND lv_line TO gt_list.
    ENDIF.
  ENDDO.
  CLOSE DATASET lv_in.

  CONCATENATE 'PROG' 'ID' 'KEY' 'ESTADO' 'TEXTO_S' 'TEXTO_E'
    INTO lv_line SEPARATED BY gv_tab.
  APPEND lv_line TO gt_out.

  LOOP AT gt_list INTO lv_line.
    lv_prog = lv_line.
    lv_progs = lv_progs + 1.
    REFRESH: lt_s, lt_e.
    READ TEXTPOOL lv_prog INTO lt_s LANGUAGE 'S'.
    READ TEXTPOOL lv_prog INTO lt_e LANGUAGE 'E'.
    DESCRIBE TABLE lt_s LINES lv_ns.
    DESCRIBE TABLE lt_e LINES lv_ne.
    IF lv_ns = 0.
      lv_nopl = lv_nopl + 1.
    ENDIF.
    SORT lt_e BY id key.
    CLEAR: lv_eq, lv_dif, lv_noe.
    LOOP AT lt_s INTO ls_s.
      READ TABLE lt_e INTO ls_e WITH KEY id = ls_s-id key = ls_s-key
        BINARY SEARCH.
      IF sy-subrc <> 0.
        lv_noe = lv_noe + 1.
        CONCATENATE lv_prog ls_s-id ls_s-key 'S_SIN_E' ls_s-entry ''
          INTO lv_line SEPARATED BY gv_tab.
        APPEND lv_line TO gt_out.
      ELSEIF ls_s-entry = ls_e-entry.
        lv_eq = lv_eq + 1.
      ELSE.
        lv_dif = lv_dif + 1.
        CONCATENATE lv_prog ls_s-id ls_s-key 'DIF' ls_s-entry ls_e-entry
          INTO lv_line SEPARATED BY gv_tab.
        APPEND lv_line TO gt_out.
      ENDIF.
    ENDLOOP.
    lv_c1 = lv_ns. lv_c2 = lv_ne. lv_c3 = lv_eq. lv_c4 = lv_dif.
    lv_c5 = lv_noe.
    CONCATENATE lv_prog '' '' 'PROG' lv_c1 lv_c2 lv_c3 lv_c4 lv_c5
      INTO lv_line SEPARATED BY gv_tab.
    APPEND lv_line TO gt_out.
    lv_tns = lv_tns + lv_ns. lv_tne = lv_tne + lv_ne.
    lv_teq = lv_teq + lv_eq. lv_tdif = lv_tdif + lv_dif.
    lv_tnoe = lv_tnoe + lv_noe.
    IF lv_dif > 0 OR lv_noe > 0.
      lv_pdif = lv_pdif + 1.
    ENDIF.
  ENDLOOP.

  OPEN DATASET lv_outp FOR OUTPUT IN TEXT MODE ENCODING UTF-8
    WITH BYTE-ORDER MARK WITH WINDOWS LINEFEED.
  IF sy-subrc <> 0.
    WRITE: / 'No se pudo crear', lv_outp.
    RETURN.
  ENDIF.
  LOOP AT gt_out INTO lv_line.
    TRANSFER lv_line TO lv_outp.
  ENDLOOP.
  CLOSE DATASET lv_outp.

  WRITE: / 'Programas leidos:      ', lv_progs,
         / 'Sin pool en S:         ', lv_nopl,
         / 'Entradas S:            ', lv_tns,
         / 'Entradas E:            ', lv_tne,
         / 'S igual a E:           ', lv_teq,
         / 'S distinto de E:       ', lv_tdif,
         / 'S sin E:               ', lv_tnoe,
         / 'Programas con difer.:  ', lv_pdif,
         / 'Archivo:', lv_outp.
ENDFORM.
