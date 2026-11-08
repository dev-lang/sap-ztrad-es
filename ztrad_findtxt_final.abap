REPORT ztrad_findtxt.
*----------------------------------------------------------------------*
* Busca en que objeto esta guardado un texto (para saber que traducir)
* Fuentes: pools de textos de programas, textos de pantalla (D021T),
*          elementos de datos (DD04T), mensajes (T100), GUI (RSMPTEXTS)
*----------------------------------------------------------------------*
DATA: gv_prog TYPE progname,
      gv_pat  TYPE string,
      gv_like TYPE string,
      gv_hits TYPE i.

PARAMETERS: p_text TYPE c LENGTH 70 LOWER CASE OBLIGATORY,
            p_lang TYPE spras DEFAULT 'E'.
SELECT-OPTIONS s_prog FOR gv_prog.
PARAMETERS: p_pool AS CHECKBOX DEFAULT 'X',
            p_dynp AS CHECKBOX DEFAULT 'X',
            p_dtel AS CHECKBOX DEFAULT 'X',
            p_msg  AS CHECKBOX DEFAULT 'X',
            p_gui  AS CHECKBOX DEFAULT 'X',
            p_max  TYPE i DEFAULT 5000.

INITIALIZATION.
  s_prog-sign = 'I'. s_prog-option = 'CP'.
  s_prog-low = 'SAPDB*'. APPEND s_prog.
  s_prog-low = 'RSDB*'.  APPEND s_prog.
  s_prog-low = 'SAPLSSEL*'. APPEND s_prog.

START-OF-SELECTION.
  gv_pat = p_text.
  CONDENSE gv_pat.
  CONCATENATE '*' gv_pat '*' INTO gv_pat.
  gv_like = p_text.
  CONDENSE gv_like.
  CONCATENATE '%' gv_like '%' INTO gv_like.

  WRITE: / 'Buscando:', p_text, 'idioma', p_lang.
  ULINE.

  IF p_pool = 'X'. PERFORM search_pool. ENDIF.
  IF p_dynp = 'X'. PERFORM search_dynp. ENDIF.
  IF p_dtel = 'X'. PERFORM search_dtel. ENDIF.
  IF p_msg  = 'X'. PERFORM search_msg.  ENDIF.
  IF p_gui  = 'X'. PERFORM search_gui.  ENDIF.

  ULINE.
  WRITE: / 'Coincidencias:', gv_hits.

*----------------------------------------------------------------------*
FORM search_pool.
  DATA: lt_prog TYPE STANDARD TABLE OF progname,
        lv_prog TYPE progname,
        lt_tp   TYPE STANDARD TABLE OF textpool,
        ls_tp   TYPE textpool.

  SELECT name FROM trdir INTO TABLE lt_prog UP TO p_max ROWS
    WHERE name IN s_prog.
  LOOP AT lt_prog INTO lv_prog.
    REFRESH lt_tp.
    READ TEXTPOOL lv_prog INTO lt_tp LANGUAGE p_lang.
    LOOP AT lt_tp INTO ls_tp.
      IF ls_tp-entry CP gv_pat OR ls_tp-key CP gv_pat.
        WRITE: / 'POOL', lv_prog(40), ls_tp-id, ls_tp-key,
                 ls_tp-entry(70).
        ADD 1 TO gv_hits.
      ENDIF.
    ENDLOOP.
  ENDLOOP.
ENDFORM.

FORM search_dynp.
  DATA: lt TYPE STANDARD TABLE OF d021t,
        ls TYPE d021t.
  SELECT * FROM d021t INTO TABLE lt UP TO p_max ROWS
    WHERE lang = p_lang AND dtxt LIKE gv_like.
  LOOP AT lt INTO ls.
    WRITE: / 'DYNP', ls-prog(40), ls-dynr, ls-fldn(30), ls-dtxt(70).
    ADD 1 TO gv_hits.
  ENDLOOP.
ENDFORM.

FORM search_dtel.
  DATA: lt  TYPE STANDARD TABLE OF dd04t,
        ls  TYPE dd04t,
        lv_l TYPE i.
  lv_l = strlen( gv_like ).
  SELECT * FROM dd04t INTO TABLE lt UP TO p_max ROWS
    WHERE ddlanguage = p_lang AND as4local = 'A' AND ddtext LIKE gv_like.
  IF lv_l <= 55.
    SELECT * FROM dd04t APPENDING TABLE lt UP TO p_max ROWS
      WHERE ddlanguage = p_lang AND as4local = 'A' AND reptext LIKE gv_like.
  ENDIF.
  IF lv_l <= 40.
    SELECT * FROM dd04t APPENDING TABLE lt UP TO p_max ROWS
      WHERE ddlanguage = p_lang AND as4local = 'A' AND scrtext_l LIKE gv_like.
  ENDIF.
  IF lv_l <= 20.
    SELECT * FROM dd04t APPENDING TABLE lt UP TO p_max ROWS
      WHERE ddlanguage = p_lang AND as4local = 'A' AND scrtext_m LIKE gv_like.
  ENDIF.
  IF lv_l <= 10.
    SELECT * FROM dd04t APPENDING TABLE lt UP TO p_max ROWS
      WHERE ddlanguage = p_lang AND as4local = 'A' AND scrtext_s LIKE gv_like.
  ENDIF.
  SORT lt BY rollname.
  DELETE ADJACENT DUPLICATES FROM lt COMPARING rollname.
  LOOP AT lt INTO ls.
    WRITE: / 'DTEL', ls-rollname(30), ls-scrtext_m(20), ls-ddtext(60).
    ADD 1 TO gv_hits.
  ENDLOOP.
ENDFORM.

FORM search_msg.
  DATA: lt TYPE STANDARD TABLE OF t100,
        ls TYPE t100.
  SELECT * FROM t100 INTO TABLE lt UP TO p_max ROWS
    WHERE sprsl = p_lang AND text LIKE gv_like.
  LOOP AT lt INTO ls.
    WRITE: / 'MESS', ls-arbgb(20), ls-msgnr, ls-text(73).
    ADD 1 TO gv_hits.
  ENDLOOP.
ENDFORM.

FORM search_gui.
  DATA: lt TYPE STANDARD TABLE OF rsmptexts,
        ls TYPE rsmptexts.
  SELECT * FROM rsmptexts INTO TABLE lt UP TO p_max ROWS
    WHERE sprsl = p_lang AND text LIKE gv_like.
  LOOP AT lt INTO ls.
    WRITE: / 'GUI ', ls-progname(40), ls-obj_type, ls-obj_code(20),
             ls-text(60).
    ADD 1 TO gv_hits.
  ENDLOOP.
ENDFORM.
