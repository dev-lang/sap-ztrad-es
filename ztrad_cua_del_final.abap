REPORT ztrad_cua_del.
*----------------------------------------------------------------------*
* Borra las cargas de textos de GUI (menus, botones, titulos) en un
* idioma para que se regeneren con las traducciones nuevas.
*----------------------------------------------------------------------*
DATA: gv_prog TYPE progname,
      gt_prog TYPE STANDARD TABLE OF progname,
      gv_cnt  TYPE i.

SELECT-OPTIONS s_prog FOR gv_prog OBLIGATORY.
PARAMETERS p_lang TYPE sylangu DEFAULT 'S'.

START-OF-SELECTION.
  SELECT name FROM trdir INTO TABLE gt_prog WHERE name IN s_prog.
  LOOP AT gt_prog INTO gv_prog.
    CALL FUNCTION 'RS_CUA_DELETE_TEXT_LOAD'
      EXPORTING
        language = p_lang
        name     = gv_prog
      EXCEPTIONS
        OTHERS   = 1.
    IF sy-subrc = 0.
      ADD 1 TO gv_cnt.
    ELSE.
      WRITE: / 'Error:', gv_prog.
    ENDIF.
  ENDLOOP.
  COMMIT WORK.
  WRITE: / 'Programas procesados:', gv_cnt.
  WRITE: / 'Ejecutar /$SYNC para verlo en sesiones abiertas.'.
