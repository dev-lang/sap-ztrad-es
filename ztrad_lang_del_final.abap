REPORT ztrad_lang_del LINE-SIZE 255.
*----------------------------------------------------------------------*
* Paso 2 de la reversion: quitar el espanol (S) que dejo el proyecto.
* Tres grupos, uno por corrida (radio):
*
*  R_TAB  Tablas de texto (S_TAB, obligatorio): borra las filas S que
*         son identicas a su fila E (todos los campos salvo el idioma).
*         - Filas S sin fila E: no se tocan.
*         - Filas S distintas de E (espanol de SAP): no se tocan.
*         - Objetos con idioma original S (TADIR-MASTERLANG = 'S'):
*           no se tocan aunque sean iguales.
*         - Solo el mandante actual en tablas dependientes de mandante.
*         Trabaja por bloques de P_CHUNK valores del primer campo clave,
*         con COMMIT por bloque.
*
*  R_DTEL Elementos de datos de la lista P_DFILE (uno por linea): borra
*         la fila S completa de DD04T (campos que el proyecto dejo en
*         blanco o que LXE no pudo pisar). Salta MASTERLANG = 'S'.
*
*  R_TPL  Pools de textos de los programas de P_PFILE ('*' = todos los
*         que tienen pool S en REPOTEXT): reescribe el pool
*         S dejando solo las entradas de SAP (S distinta de E o S sin E)
*         que no esten en P_OFILE (PROG<tab>ID<tab>KEY, entradas del
*         proyecto). Si no queda nada, DELETE TEXTPOOL ... LANGUAGE 'S'.
*         Salta programas / grupos de funciones con MASTERLANG = 'S'.
*         P_TMODE = 'B' (defecto): en pools mixtos (con alguna entrada
*         de SAP) solo quita las entradas de P_OFILE. 'A': quita tambien
*         las entradas iguales a E.
*
* P_TEST = 'X' (por defecto): no modifica nada, solo cuenta.
* P_OUT: informe TSV (totales por tabla/programa y muestras).
* Control: cuenta filas E y D antes y despues de cada tabla.
* Rutas relativas a C:\Users\user\Documents\ztrad_rfc_files\
* Despues de una corrida real: /$SYNC (buffers de tablas y textos).
*----------------------------------------------------------------------*
TYPES: BEGIN OF ty_kx,
         k TYPE string,
         i TYPE i,
       END OF ty_kx.
TYPES: BEGIN OF ty_s,
         s TYPE string,
       END OF ty_s.

DATA: gt_out  TYPE STANDARD TABLE OF string,
      gv_tab  TYPE c,
      gv_tabn TYPE tabname,
      gv_line TYPE string.

SELECT-OPTIONS s_tab FOR gv_tabn NO INTERVALS.
PARAMETERS: r_tab  RADIOBUTTON GROUP grp DEFAULT 'X',
            r_dtel RADIOBUTTON GROUP grp,
            r_tpl  RADIOBUTTON GROUP grp,
            p_test AS CHECKBOX DEFAULT 'X',
            p_chunk TYPE i DEFAULT 200,
            p_smp   TYPE i DEFAULT 30,
            p_dfile TYPE char45 LOWER CASE,
            p_pfile TYPE char45 LOWER CASE,
            p_ofile TYPE char45 LOWER CASE,
            p_tmode TYPE c DEFAULT 'B',
            p_out   TYPE char45 LOWER CASE OBLIGATORY.
PARAMETERS p_mem TYPE indx-srtfd NO-DISPLAY.
CONSTANTS c_base TYPE string VALUE 'C:\Users\user\Documents\ztrad_rfc_files\'.

START-OF-SELECTION.
  gv_tab = cl_abap_char_utilities=>horizontal_tab.
  IF p_test = 'X'.
    WRITE: / 'MODO TEST: no se modifica nada.'.
    APPEND 'MODO TEST' TO gt_out.
  ELSE.
    WRITE: / 'MODO REAL.'.
    APPEND 'MODO REAL' TO gt_out.
  ENDIF.
  IF p_chunk < 1.
    p_chunk = 200.
  ENDIF.
  IF r_tab = 'X'.
    PERFORM do_tables.
  ELSEIF r_dtel = 'X'.
    PERFORM do_dtel.
  ELSE.
    PERFORM do_tpool.
  ENDIF.
  PERFORM write_out.

*----------------------------------------------------------------------*
FORM path USING iv_rel TYPE char45 CHANGING cv_path TYPE string
                                            cv_rc   TYPE i.
  cv_rc = 0.
  IF iv_rel IS INITIAL OR iv_rel CS '..' OR iv_rel CS ':'
     OR iv_rel(1) = '\' OR iv_rel(1) = '/'.
    WRITE: / 'Ruta no permitida o vacia:', iv_rel.
    cv_rc = 1.
    RETURN.
  ENDIF.
  CONCATENATE c_base iv_rel INTO cv_path.
ENDFORM.

FORM read_file USING iv_rel TYPE char45 CHANGING ct_lines TYPE string_table
                                                 cv_rc    TYPE i.
  DATA: lv_path TYPE string,
        lv_line TYPE string.
  REFRESH ct_lines.
  PERFORM path USING iv_rel CHANGING lv_path cv_rc.
  IF cv_rc <> 0.
    RETURN.
  ENDIF.
  OPEN DATASET lv_path FOR INPUT IN TEXT MODE ENCODING UTF-8
    SKIPPING BYTE-ORDER MARK WITH WINDOWS LINEFEED.
  IF sy-subrc <> 0.
    WRITE: / 'No se pudo abrir', lv_path.
    cv_rc = 1.
    RETURN.
  ENDIF.
  DO.
    READ DATASET lv_path INTO lv_line.
    IF sy-subrc <> 0.
      EXIT.
    ENDIF.
    IF lv_line IS NOT INITIAL.
      APPEND lv_line TO ct_lines.
    ENDIF.
  ENDDO.
  CLOSE DATASET lv_path.
ENDFORM.

FORM write_out.
  DATA: lv_path TYPE string,
        lv_rc   TYPE i,
        lv_line TYPE string.
  PERFORM path USING p_out CHANGING lv_path lv_rc.
  IF lv_rc <> 0.
    RETURN.
  ENDIF.
  OPEN DATASET lv_path FOR OUTPUT IN TEXT MODE ENCODING UTF-8
    WITH BYTE-ORDER MARK WITH WINDOWS LINEFEED.
  IF sy-subrc <> 0.
    WRITE: / 'No se pudo crear', lv_path.
    RETURN.
  ENDIF.
  LOOP AT gt_out INTO lv_line.
    TRANSFER lv_line TO lv_path.
  ENDLOOP.
  CLOSE DATASET lv_path.
  WRITE: / 'Informe:', lv_path.
ENDFORM.

* Literal SQL entre comillas simples (vacio -> ' ')
FORM quote USING iv_v TYPE string CHANGING cv_q TYPE string.
  cv_q = iv_v.
  IF cv_q IS INITIAL.
    cv_q = `' '`.
    RETURN.
  ENDIF.
  REPLACE ALL OCCURRENCES OF `'` IN cv_q WITH `''`.
  CONCATENATE `'` cv_q `'` INTO cv_q.
ENDFORM.

FORM add_n USING iv_n TYPE i.
  DATA lv_c(12) TYPE c.
  lv_c = iv_n.
  CONDENSE lv_c.
  CONCATENATE gv_line lv_c INTO gv_line SEPARATED BY gv_tab.
ENDFORM.

* Objetos con idioma original espanol (TADIR) para el tipo dado
FORM load_ml USING iv_obj TYPE trobjtype
             CHANGING ct_ml TYPE HASHED TABLE.
  DATA: lt_n TYPE STANDARD TABLE OF sobj_name,
        lv_n TYPE sobj_name,
        ls_s TYPE ty_s.
  CLEAR ct_ml.
  IF iv_obj IS INITIAL.
    RETURN.
  ENDIF.
  SELECT obj_name FROM tadir INTO TABLE lt_n
    WHERE pgmid = 'R3TR' AND object = iv_obj AND masterlang = 'S'.
  LOOP AT lt_n INTO lv_n.
    ls_s-s = lv_n.
    INSERT ls_s INTO TABLE ct_ml.
  ENDLOOP.
  IF iv_obj = 'PROG'.
    DATA: lv_ns  TYPE string,
          lv_rst TYPE string,
          lt_pg  TYPE STANDARD TABLE OF progname,
          lv_pg  TYPE progname.
    REFRESH lt_n.
    SELECT obj_name FROM tadir INTO TABLE lt_n
      WHERE pgmid = 'R3TR' AND object = 'FUGR' AND masterlang = 'S'.
    LOOP AT lt_n INTO lv_n.
*     /NS/GRUPO -> /NS/SAPLGRUPO ; GRUPO -> SAPLGRUPO
      IF lv_n(1) = '/'.
        lv_rst = lv_n+1.
        SPLIT lv_rst AT '/' INTO lv_ns lv_rst.
        CONCATENATE '/' lv_ns '/SAPL' lv_rst INTO ls_s-s.
      ELSE.
        CONCATENATE 'SAPL' lv_n INTO ls_s-s.
      ENDIF.
      INSERT ls_s INTO TABLE ct_ml.
    ENDLOOP.
*   Cualquier programa (class pools, LDB, generados, etc.) cuyo idioma
*   original en TRDIR es espanol
    SELECT name FROM trdir INTO TABLE lt_pg WHERE rload = 'S'.
    LOOP AT lt_pg INTO lv_pg.
      ls_s-s = lv_pg.
      INSERT ls_s INTO TABLE ct_ml.
    ENDLOOP.
  ENDIF.
ENDFORM.

FORM count_lang USING iv_tab TYPE tabname iv_lang TYPE string
                      iv_val TYPE c CHANGING cv_n TYPE i.
  DATA lv_wh TYPE string.
  CONCATENATE iv_lang ` = '` iv_val `'` INTO lv_wh.
  SELECT COUNT(*) FROM (iv_tab) INTO cv_n WHERE (lv_wh).
ENDFORM.

*----------------------------------------------------------------------*
* Grupo 1: tablas de texto
*----------------------------------------------------------------------*
FORM do_tables.
  DATA: lt_dd02 TYPE STANDARD TABLE OF dd02l,
        ls_dd02 TYPE dd02l.
  IF s_tab[] IS INITIAL.
    WRITE: / 'Indicar las tablas en S_TAB.'.
    RETURN.
  ENDIF.
  SELECT * FROM dd02l INTO TABLE lt_dd02
    WHERE tabname IN s_tab AND as4local = 'A'
      AND tabclass IN ('TRANSP','POOL','CLUSTER').
  SORT lt_dd02 BY tabname.
  CONCATENATE 'TABLA' 'S_ANTES' 'BORRADAS' 'S_DISTINTA_E' 'S_SIN_E'
              'MASTERLANG_S' 'S_DESPUES' 'E_ANTES' 'E_DESPUES'
              'D_ANTES' 'D_DESPUES'
    INTO gv_line SEPARATED BY gv_tab.
  APPEND gv_line TO gt_out.
  LOOP AT lt_dd02 INTO ls_dd02.
    PERFORM do_table USING ls_dd02-tabname ls_dd02-tabclass.
  ENDLOOP.
ENDFORM.

FORM do_table USING pv_tab TYPE tabname pv_cls TYPE tabclass.
  DATA: lt_f      TYPE STANDARD TABLE OF dd03l,
        ls_f      TYPE dd03l,
        lt_keys   TYPE string_table,
        lv_key    TYPE string,
        lv_lang   TYPE string,
        lv_k1     TYPE string,
        lv_k1t    TYPE string,
        lv_obj    TYPE trobjtype,
        lt_ml     TYPE HASHED TABLE OF ty_s WITH UNIQUE KEY s,
        lt_mlv    TYPE HASHED TABLE OF ty_s WITH UNIQUE KEY s,
        ls_s      TYPE ty_s,
        lr_k1     TYPE REF TO data,
        lr_st     TYPE REF TO data,
        lr_et     TYPE REF TO data,
        lr_dt     TYPE REF TO data,
        lr_w      TYPE REF TO data,
        lt_kx     TYPE HASHED TABLE OF ty_kx WITH UNIQUE KEY k,
        ls_kx     TYPE ty_kx,
        lv_from   TYPE i,
        lv_to     TYPE i,
        lv_nk1    TYPE i,
        lv_i      TYPE i,
        lv_v      TYPE string,
        lv_q      TYPE string,
        lv_in     TYPE string,
        lv_ws     TYPE string,
        lv_we     TYPE string,
        lv_ks     TYPE string,
        lv_s0     TYPE i,
        lv_s1     TYPE i,
        lv_e0     TYPE i,
        lv_e1     TYPE i,
        lv_d0     TYPE i,
        lv_d1     TYPE i,
        lv_del    TYPE i,
        lv_dif    TYPE i,
        lv_noe    TYPE i,
        lv_nml    TYPE i,
        lv_smp    TYPE i,
        lv_ndif   TYPE i,
        lt_c      TYPE string_table.
  FIELD-SYMBOLS: <k1t> TYPE STANDARD TABLE,
                 <k1>  TYPE any,
                 <st>  TYPE STANDARD TABLE,
                 <et>  TYPE STANDARD TABLE,
                 <dt>  TYPE STANDARD TABLE,
                 <s>   TYPE any,
                 <e>   TYPE any,
                 <w>   TYPE any,
                 <f>   TYPE any.

* Metadatos: idioma (clave LANG) y claves (sin mandante ni idioma)
  SELECT * FROM dd03l INTO TABLE lt_f
    WHERE tabname = pv_tab AND as4local = 'A' ORDER BY position.
  LOOP AT lt_f INTO ls_f WHERE keyflag = 'X'.
    CHECK ls_f-fieldname(1) <> '.'.
    IF ls_f-datatype = 'CLNT'.
      CONTINUE.
    ELSEIF ls_f-datatype = 'LANG' AND lv_lang IS INITIAL.
      lv_lang = ls_f-fieldname.
    ELSE.
      lv_key = ls_f-fieldname.
      APPEND lv_key TO lt_keys.
    ENDIF.
  ENDLOOP.
  READ TABLE lt_keys INTO lv_k1 INDEX 1.
  IF lv_lang IS INITIAL OR lv_k1 IS INITIAL.
    CONCATENATE pv_tab 'SALTEADA: sin campo idioma clave o sin otra clave'
      INTO gv_line SEPARATED BY gv_tab.
    APPEND gv_line TO gt_out.
    WRITE: / pv_tab, 'salteada (sin idioma clave)'.
    RETURN.
  ENDIF.

  CASE pv_tab.
    WHEN 'DD01T' OR 'DD07T'. lv_obj = 'DOMA'.
    WHEN 'DD02T'.            lv_obj = 'TABL'.
    WHEN 'DD04T'.            lv_obj = 'DTEL'.
    WHEN 'DD30T'.            lv_obj = 'SHLP'.
    WHEN 'T100'.             lv_obj = 'MSAG'.
    WHEN 'TSTCT'.            lv_obj = 'TRAN'.
    WHEN 'D020T' OR 'D021T' OR 'RSMPTEXTS'. lv_obj = 'PROG'.
    WHEN OTHERS.             CLEAR lv_obj.
  ENDCASE.
  PERFORM load_ml USING lv_obj CHANGING lt_ml.
  IF pv_tab = 'DD02T'.
*   DD02T tambien guarda textos de vistas
    PERFORM load_ml USING 'VIEW' CHANGING lt_mlv.
    LOOP AT lt_mlv INTO ls_s.
      INSERT ls_s INTO TABLE lt_ml.
    ENDLOOP.
  ENDIF.

  PERFORM count_lang USING pv_tab lv_lang 'S' CHANGING lv_s0.
  PERFORM count_lang USING pv_tab lv_lang 'E' CHANGING lv_e0.
  PERFORM count_lang USING pv_tab lv_lang 'D' CHANGING lv_d0.

* Valores distintos del primer campo clave con filas S
  CONCATENATE pv_tab '-' lv_k1 INTO lv_k1t.
  CREATE DATA lr_k1 TYPE STANDARD TABLE OF (lv_k1t).
  ASSIGN lr_k1->* TO <k1t>.
  CONCATENATE lv_lang ` = 'S'` INTO lv_ws.
* SELECT DISTINCT no esta permitido en tablas pool/cluster
  IF pv_cls = 'TRANSP'.
    SELECT DISTINCT (lv_k1) FROM (pv_tab) INTO TABLE <k1t> WHERE (lv_ws).
    SORT <k1t>.
  ELSE.
    SELECT (lv_k1) FROM (pv_tab) INTO TABLE <k1t> WHERE (lv_ws).
    SORT <k1t>.
    DELETE ADJACENT DUPLICATES FROM <k1t>.
  ENDIF.
  DESCRIBE TABLE <k1t> LINES lv_nk1.

  CREATE DATA lr_st TYPE STANDARD TABLE OF (pv_tab).
  CREATE DATA lr_et TYPE STANDARD TABLE OF (pv_tab).
  CREATE DATA lr_dt TYPE STANDARD TABLE OF (pv_tab).
  CREATE DATA lr_w  TYPE (pv_tab).
  ASSIGN lr_st->* TO <st>.
  ASSIGN lr_et->* TO <et>.
  ASSIGN lr_dt->* TO <dt>.
  ASSIGN lr_w->*  TO <w>.

  lv_from = 1.
  WHILE lv_from <= lv_nk1.
    lv_to = lv_from + p_chunk - 1.
    IF lv_to > lv_nk1.
      lv_to = lv_nk1.
    ENDIF.
*   IN ( ... ) con los valores del bloque
    CLEAR lv_in.
    LOOP AT <k1t> ASSIGNING <k1> FROM lv_from TO lv_to.
      lv_v = <k1>.
      PERFORM quote USING lv_v CHANGING lv_q.
      IF lv_in IS INITIAL.
        lv_in = lv_q.
      ELSE.
        CONCATENATE lv_in `,` lv_q INTO lv_in.
      ENDIF.
    ENDLOOP.
    CONCATENATE lv_lang ` = 'S' AND ` lv_k1 ` IN (` lv_in `)` INTO lv_ws.
    CONCATENATE lv_lang ` = 'E' AND ` lv_k1 ` IN (` lv_in `)` INTO lv_we.
    REFRESH: <st>, <et>, <dt>.
    CLEAR lt_kx.
    SELECT * FROM (pv_tab) INTO TABLE <st> WHERE (lv_ws).
    SELECT * FROM (pv_tab) INTO TABLE <et> WHERE (lv_we).

*   Indice de E por clave
    LOOP AT <et> ASSIGNING <e>.
      lv_i = sy-tabix.
      CLEAR lv_ks.
      LOOP AT lt_keys INTO lv_key.
        ASSIGN COMPONENT lv_key OF STRUCTURE <e> TO <f>.
        lv_v = <f>.
        CONCATENATE lv_ks lv_v INTO lv_ks SEPARATED BY '|'.
      ENDLOOP.
      ls_kx-k = lv_ks.
      ls_kx-i = lv_i.
      INSERT ls_kx INTO TABLE lt_kx.
    ENDLOOP.

    LOOP AT <st> ASSIGNING <s>.
      CLEAR lv_ks.
      LOOP AT lt_keys INTO lv_key.
        ASSIGN COMPONENT lv_key OF STRUCTURE <s> TO <f>.
        lv_v = <f>.
        CONCATENATE lv_ks lv_v INTO lv_ks SEPARATED BY '|'.
      ENDLOOP.
*     Objeto con idioma original espanol
      IF lt_ml IS NOT INITIAL.
        ASSIGN COMPONENT lv_k1 OF STRUCTURE <s> TO <f>.
        ls_s-s = <f>.
        READ TABLE lt_ml WITH TABLE KEY s = ls_s-s TRANSPORTING NO FIELDS.
        IF sy-subrc = 0.
          lv_nml = lv_nml + 1.
          CONTINUE.
        ENDIF.
      ENDIF.
      READ TABLE lt_kx INTO ls_kx WITH TABLE KEY k = lv_ks.
      IF sy-subrc <> 0.
        lv_noe = lv_noe + 1.
        CONTINUE.
      ENDIF.
      READ TABLE <et> ASSIGNING <e> INDEX ls_kx-i.
      <w> = <s>.
      ASSIGN COMPONENT lv_lang OF STRUCTURE <w> TO <f>.
      <f> = 'E'.
      IF <w> = <e>.
        APPEND <s> TO <dt>.
        IF lv_smp < p_smp.
          lv_smp = lv_smp + 1.
          CONCATENATE pv_tab 'MUESTRA_BORRA' lv_ks INTO gv_line
            SEPARATED BY gv_tab.
          APPEND gv_line TO lt_c.
        ENDIF.
      ELSE.
        lv_dif = lv_dif + 1.
        IF lv_ndif < p_smp.
          lv_ndif = lv_ndif + 1.
          CONCATENATE pv_tab 'MUESTRA_QUEDA_DIF' lv_ks INTO gv_line
            SEPARATED BY gv_tab.
          APPEND gv_line TO lt_c.
        ENDIF.
      ENDIF.
    ENDLOOP.

    DESCRIBE TABLE <dt> LINES lv_i.
    IF lv_i > 0.
      IF p_test = 'X'.
        lv_del = lv_del + lv_i.
      ELSE.
        DELETE (pv_tab) FROM TABLE <dt>.
        lv_del = lv_del + sy-dbcnt.
        COMMIT WORK.
      ENDIF.
    ENDIF.
    lv_from = lv_to + 1.
  ENDWHILE.

  PERFORM count_lang USING pv_tab lv_lang 'S' CHANGING lv_s1.
  PERFORM count_lang USING pv_tab lv_lang 'E' CHANGING lv_e1.
  PERFORM count_lang USING pv_tab lv_lang 'D' CHANGING lv_d1.

  gv_line = pv_tab.
  PERFORM add_n USING lv_s0.  PERFORM add_n USING lv_del.
  PERFORM add_n USING lv_dif. PERFORM add_n USING lv_noe.
  PERFORM add_n USING lv_nml. PERFORM add_n USING lv_s1.
  PERFORM add_n USING lv_e0.  PERFORM add_n USING lv_e1.
  PERFORM add_n USING lv_d0.  PERFORM add_n USING lv_d1.
  APPEND gv_line TO gt_out.
  APPEND LINES OF lt_c TO gt_out.

  WRITE: / pv_tab, 'S antes', lv_s0, 'borradas', lv_del,
           'S<>E', lv_dif, 'S sin E', lv_noe, 'orig.S', lv_nml.
  WRITE: / '      S despues', lv_s1, 'E', lv_e0, '->', lv_e1,
           'D', lv_d0, '->', lv_d1.
  IF p_test <> 'X' AND lv_s1 <> lv_s0 - lv_del.
    WRITE: / '      *** ATENCION: S despues <> S antes - borradas ***'.
    CONCATENATE pv_tab '*** ATENCION: S despues no cierra' INTO gv_line
      SEPARATED BY gv_tab.
    APPEND gv_line TO gt_out.
  ENDIF.
  IF lv_e0 <> lv_e1 OR lv_d0 <> lv_d1.
    WRITE: / '      *** ATENCION: cambio la cantidad de filas E o D ***'.
    CONCATENATE pv_tab '*** ATENCION: cambio E o D' INTO gv_line
      SEPARATED BY gv_tab.
    APPEND gv_line TO gt_out.
  ENDIF.
ENDFORM.

*----------------------------------------------------------------------*
* Grupo 2: filas S completas de DD04T para la lista de elementos
*----------------------------------------------------------------------*
FORM do_dtel.
  DATA: lt_l    TYPE string_table,
        lv_l    TYPE string,
        lv_rc   TYPE i,
        lt_ml   TYPE HASHED TABLE OF ty_s WITH UNIQUE KEY s,
        ls_s    TYPE ty_s,
        lt_nam  TYPE string_table,
        lt_d    TYPE STANDARD TABLE OF dd04t,
        ls_d    TYPE dd04t,
        lv_in   TYPE string,
        lv_q    TYPE string,
        lv_wh   TYPE string,
        lv_n    TYPE i,
        lv_from TYPE i,
        lv_to   TYPE i,
        lv_i    TYPE i,
        lv_nml  TYPE i,
        lv_del  TYPE i,
        lv_e0   TYPE i,
        lv_e1   TYPE i,
        lv_c(12) TYPE c.

  PERFORM read_file USING p_dfile CHANGING lt_l lv_rc.
  IF lv_rc <> 0.
    RETURN.
  ENDIF.
  PERFORM load_ml USING 'DTEL' CHANGING lt_ml.
  LOOP AT lt_l INTO lv_l.
    CONDENSE lv_l.
    TRANSLATE lv_l TO UPPER CASE.
    ls_s-s = lv_l.
    READ TABLE lt_ml WITH TABLE KEY s = ls_s-s TRANSPORTING NO FIELDS.
    IF sy-subrc = 0.
      lv_nml = lv_nml + 1.
      CONCATENATE 'DD04T' 'SALTEADO_MASTERLANG_S' lv_l INTO gv_line
        SEPARATED BY gv_tab.
      APPEND gv_line TO gt_out.
      CONTINUE.
    ENDIF.
    APPEND lv_l TO lt_nam.
  ENDLOOP.
  SORT lt_nam.
  DELETE ADJACENT DUPLICATES FROM lt_nam.
  DESCRIBE TABLE lt_nam LINES lv_n.

  SELECT COUNT(*) FROM dd04t INTO lv_e0 WHERE ddlanguage = 'E'.
  lv_from = 1.
  WHILE lv_from <= lv_n.
    lv_to = lv_from + p_chunk - 1.
    IF lv_to > lv_n.
      lv_to = lv_n.
    ENDIF.
    CLEAR lv_in.
    LOOP AT lt_nam INTO lv_l FROM lv_from TO lv_to.
      PERFORM quote USING lv_l CHANGING lv_q.
      IF lv_in IS INITIAL.
        lv_in = lv_q.
      ELSE.
        CONCATENATE lv_in `,` lv_q INTO lv_in.
      ENDIF.
    ENDLOOP.
    CONCATENATE `DDLANGUAGE = 'S' AND ROLLNAME IN (` lv_in `)` INTO lv_wh.
    REFRESH lt_d.
    SELECT * FROM dd04t INTO TABLE lt_d WHERE (lv_wh).
    LOOP AT lt_d INTO ls_d.
      CONCATENATE 'DD04T' 'BORRA' ls_d-rollname ls_d-as4local
                  ls_d-ddtext ls_d-reptext ls_d-scrtext_s
                  ls_d-scrtext_m ls_d-scrtext_l
        INTO gv_line SEPARATED BY gv_tab.
      APPEND gv_line TO gt_out.
    ENDLOOP.
    DESCRIBE TABLE lt_d LINES lv_i.
    IF lv_i > 0.
      IF p_test = 'X'.
        lv_del = lv_del + lv_i.
      ELSE.
        DELETE dd04t FROM TABLE lt_d.
        lv_del = lv_del + sy-dbcnt.
        COMMIT WORK.
      ENDIF.
    ENDIF.
    lv_from = lv_to + 1.
  ENDWHILE.
  SELECT COUNT(*) FROM dd04t INTO lv_e1 WHERE ddlanguage = 'E'.

  WRITE: / 'Elementos en la lista:', lv_n, 'salteados orig.S:', lv_nml,
         / 'Filas S de DD04T borradas:', lv_del,
         / 'Filas E de DD04T:', lv_e0, '->', lv_e1.
  lv_c = lv_del. CONDENSE lv_c.
  CONCATENATE 'TOTAL' 'BORRADAS' lv_c INTO gv_line SEPARATED BY gv_tab.
  APPEND gv_line TO gt_out.
  IF lv_e0 <> lv_e1.
    WRITE: / '*** ATENCION: cambio la cantidad de filas E ***'.
    APPEND '*** ATENCION: cambio la cantidad de filas E' TO gt_out.
  ENDIF.
ENDFORM.

*----------------------------------------------------------------------*
* Grupo 3: pools de textos
*----------------------------------------------------------------------*
FORM do_tpool.
  DATA: lt_p     TYPE string_table,
        lt_o     TYPE string_table,
        lv_l     TYPE string,
        lv_rc    TYPE i,
        lt_ours  TYPE HASHED TABLE OF ty_s WITH UNIQUE KEY s,
        lt_ml    TYPE HASHED TABLE OF ty_s WITH UNIQUE KEY s,
        ls_s     TYPE ty_s,
        lv_p     TYPE string,
        lv_id    TYPE string,
        lv_k     TYPE string,
        lv_prog  TYPE progname,
        lt_s     TYPE STANDARD TABLE OF textpool,
        lt_e     TYPE STANDARD TABLE OF textpool,
        lt_new   TYPE STANDARD TABLE OF textpool,
        lt_nol   TYPE STANDARD TABLE OF textpool,
        lv_dlist TYPE i,
        lv_pmix  TYPE i,
        ls_t     TYPE textpool,
        ls_e     TYPE textpool,
        lv_drop  TYPE i,
        lv_keep  TYPE i,
        lv_tdrop TYPE i,
        lv_tkeep TYPE i,
        lv_tours TYPE i,
        lv_pdel  TYPE i,
        lv_prew  TYPE i,
        lv_pml   TYPE i,
        lv_pn    TYPE i,
        lv_cnt   TYPE i,
        lv_c1(12) TYPE c,
        lv_c2(12) TYPE c.

  IF p_pfile = '*'.
*   Todos los programas que tienen pool de textos en espanol
    DATA lt_pn TYPE STANDARD TABLE OF progname.
    DATA lv_pnm TYPE progname.
    DATA lv_lf TYPE fieldname.
    DATA lv_pw TYPE string.
*   Campo de idioma de REPOTEXT segun el diccionario
    SELECT SINGLE fieldname FROM dd03l INTO lv_lf
      WHERE tabname = 'REPOTEXT' AND as4local = 'A' AND datatype = 'LANG'.
    IF sy-subrc <> 0.
      WRITE: / 'REPOTEXT sin campo de idioma.'.
      RETURN.
    ENDIF.
    CONCATENATE lv_lf ` = 'S'` INTO lv_pw.
    SELECT DISTINCT progname FROM repotext INTO TABLE lt_pn
      WHERE (lv_pw).
    LOOP AT lt_pn INTO lv_pnm.
      lv_l = lv_pnm.
      APPEND lv_l TO lt_p.
    ENDLOOP.
    FREE lt_pn.
  ELSE.
    PERFORM read_file USING p_pfile CHANGING lt_p lv_rc.
    IF lv_rc <> 0.
      RETURN.
    ENDIF.
  ENDIF.
  IF p_ofile IS NOT INITIAL.
    PERFORM read_file USING p_ofile CHANGING lt_o lv_rc.
    IF lv_rc <> 0.
      RETURN.
    ENDIF.
  ENDIF.
  LOOP AT lt_o INTO lv_l.
    SPLIT lv_l AT gv_tab INTO lv_p lv_id lv_k.
    CONDENSE: lv_p, lv_id, lv_k.
    CONCATENATE lv_p lv_id lv_k INTO ls_s-s SEPARATED BY '|'.
    INSERT ls_s INTO TABLE lt_ours.
  ENDLOOP.
  PERFORM load_ml USING 'PROG' CHANGING lt_ml.

  CONCATENATE 'PROG' 'ACCION' 'QUITADAS' 'QUEDAN_SAP' INTO gv_line
    SEPARATED BY gv_tab.
  APPEND gv_line TO gt_out.

  LOOP AT lt_p INTO lv_l.
    CONDENSE lv_l.
    lv_prog = lv_l.
    lv_pn = lv_pn + 1.
    ls_s-s = lv_prog.
    READ TABLE lt_ml WITH TABLE KEY s = ls_s-s TRANSPORTING NO FIELDS.
    IF sy-subrc = 0.
      lv_pml = lv_pml + 1.
      CONTINUE.
    ENDIF.
    REFRESH: lt_s, lt_e, lt_new, lt_nol.
    CLEAR lv_dlist.
    READ TEXTPOOL lv_prog INTO lt_s LANGUAGE 'S'.
    IF lt_s IS INITIAL.
      CONTINUE.
    ENDIF.
    READ TEXTPOOL lv_prog INTO lt_e LANGUAGE 'E'.
    SORT lt_e BY id key.
    CLEAR: lv_drop, lv_keep.
    LOOP AT lt_s INTO ls_t.
      lv_id = ls_t-id.
      lv_k  = ls_t-key.
      CONDENSE lv_k.
      CONCATENATE lv_l lv_id lv_k INTO ls_s-s SEPARATED BY '|'.
      READ TABLE lt_ours WITH TABLE KEY s = ls_s-s TRANSPORTING NO FIELDS.
      IF sy-subrc = 0.
        lv_drop = lv_drop + 1.
        lv_tours = lv_tours + 1.
        lv_dlist = lv_dlist + 1.
        CONCATENATE lv_l 'QUITA_LISTA' lv_id lv_k ls_t-entry INTO gv_line
          SEPARATED BY gv_tab.
        APPEND gv_line TO gt_out.
        CONTINUE.
      ENDIF.
      APPEND ls_t TO lt_nol.
      READ TABLE lt_e INTO ls_e WITH KEY id = ls_t-id key = ls_t-key
        BINARY SEARCH.
      IF sy-subrc = 0 AND ls_e-entry = ls_t-entry.
        lv_drop = lv_drop + 1.
      ELSE.
        lv_keep = lv_keep + 1.
        APPEND ls_t TO lt_new.
      ENDIF.
    ENDLOOP.
*   Modo B: en pools mixtos (con al menos una entrada de SAP) solo se
*   quitan las entradas de la lista P_OFILE; el resto queda como esta.
    IF p_tmode = 'B' AND lv_keep > 0.
      lv_pmix = lv_pmix + 1.
      lt_new[] = lt_nol[].
      lv_drop = lv_dlist.
      DESCRIBE TABLE lt_new LINES lv_keep.
    ENDIF.
    IF lv_drop = 0.
      CONTINUE.
    ENDIF.
    lv_tdrop = lv_tdrop + lv_drop.
    lv_tkeep = lv_tkeep + lv_keep.
    IF lt_new IS INITIAL.
      lv_pdel = lv_pdel + 1.
      CONCATENATE lv_l 'BORRA_POOL' INTO gv_line SEPARATED BY gv_tab.
      APPEND gv_line TO gt_out.
      IF p_test <> 'X'.
        DELETE TEXTPOOL lv_prog LANGUAGE 'S'.
        IF sy-subrc <> 0.
          CONCATENATE lv_l '*** ERROR DELETE TEXTPOOL' INTO gv_line
            SEPARATED BY gv_tab.
          APPEND gv_line TO gt_out.
        ENDIF.
      ENDIF.
    ELSE.
      lv_prew = lv_prew + 1.
      lv_c1 = lv_drop. CONDENSE lv_c1.
      lv_c2 = lv_keep. CONDENSE lv_c2.
      CONCATENATE lv_l 'REESCRIBE' lv_c1 lv_c2 INTO gv_line
        SEPARATED BY gv_tab.
      APPEND gv_line TO gt_out.
      IF p_test <> 'X'.
        INSERT TEXTPOOL lv_prog FROM lt_new LANGUAGE 'S'.
        IF sy-subrc <> 0.
          CONCATENATE lv_l '*** ERROR INSERT TEXTPOOL' INTO gv_line
            SEPARATED BY gv_tab.
          APPEND gv_line TO gt_out.
        ENDIF.
      ENDIF.
    ENDIF.
    lv_cnt = lv_cnt + 1.
    IF p_test <> 'X' AND lv_cnt >= 200.
      COMMIT WORK.
      CLEAR lv_cnt.
    ENDIF.
  ENDLOOP.
  IF p_test <> 'X'.
    COMMIT WORK.
  ENDIF.

  WRITE: / 'Modo pools mixtos (A/B):      ', p_tmode,
         / 'Pools mixtos (con texto SAP): ', lv_pmix,
         / 'Programas en la lista:        ', lv_pn,
         / 'Salteados (original S):       ', lv_pml,
         / 'Pool S borrado entero:        ', lv_pdel,
         / 'Pool S reescrito (queda SAP): ', lv_prew,
         / 'Entradas S quitadas:          ', lv_tdrop,
         / '  de ellas, de la lista P_OFILE:', lv_tours,
         / 'Entradas S de SAP que quedan: ', lv_tkeep.
  lv_c1 = lv_pdel. CONDENSE lv_c1.
  lv_c2 = lv_tdrop. CONDENSE lv_c2.
  CONCATENATE 'TOTAL' 'POOLS_BORRADOS' lv_c1 'ENTRADAS_QUITADAS' lv_c2
    INTO gv_line SEPARATED BY gv_tab.
  APPEND gv_line TO gt_out.
ENDFORM.
