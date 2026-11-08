REPORT ztrad_dynp_del.
*----------------------------------------------------------------------*
* Borra cargas de textos de pantallas (DYNPTXTLD) de un idioma para que
* SAP las regenere desde D021T en el proximo acceso.
* DB_DROP_DYNP_TEXT_LOADS no soporta Sybase: se usa SQL nativo.
*----------------------------------------------------------------------*
DATA: gv_cnt  TYPE i,
      gv_prog TYPE progname,
      gv_lang TYPE spras.

PARAMETERS: p_prog  TYPE progname,
            p_lang  TYPE spras DEFAULT 'S' OBLIGATORY,
            p_all   AS CHECKBOX,
            p_test  AS CHECKBOX DEFAULT 'X'.

START-OF-SELECTION.
  gv_lang = p_lang.
  gv_prog = p_prog.

  IF p_all IS INITIAL AND p_prog IS INITIAL.
    WRITE: / 'Indicar programa o marcar P_ALL'.
    RETURN.
  ENDIF.

  IF p_all = 'X'.
    SELECT COUNT(*) FROM dynptxtld INTO gv_cnt WHERE language = gv_lang.
  ELSE.
    SELECT COUNT(*) FROM dynptxtld INTO gv_cnt
      WHERE progname = gv_prog AND language = gv_lang.
  ENDIF.
  WRITE: / 'Cargas encontradas:', gv_cnt.

  IF p_test = 'X'.
    WRITE: / '*** MODO TEST: no se borro nada ***'.
    RETURN.
  ENDIF.

  IF p_all = 'X'.
    EXEC SQL.
      DELETE FROM DYNPTXTLD WHERE LANGUAGE = :gv_lang
    ENDEXEC.
  ELSE.
    EXEC SQL.
      DELETE FROM DYNPTXTLD WHERE PROGNAME = :gv_prog AND LANGUAGE = :gv_lang
    ENDEXEC.
  ENDIF.
  gv_cnt = sy-dbcnt.
  COMMIT WORK.
  WRITE: / 'Cargas borradas:', gv_cnt.
