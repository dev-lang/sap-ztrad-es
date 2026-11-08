*----------------------------------------------------------------------*
* ZCL_ZTRAD_HTTP - servicio HTTP para correr los ZTRAD_* sin SAP GUI
* Nodo SICF: /default_host/zztrad   (handler: ZCL_ZTRAD_HTTP)
*
*   GET  /zztrad/ping
*   POST /zztrad/run?prog=ZTRAD_LXE&p_type=DTEL&r_imp=X&r_exp=&p_test=X
*        cuerpo = TSV UTF-8 (solo para import). Programa el job en fondo.
*        Parametros: P_* / R_* -> parametro; S_* -> select-option
*        (con * o + usa CP, si no EQ; se puede repetir s_name=...).
*   GET  /zztrad/status?job=ZTRAD_HTTP&count=NNNNNNNN
*        status del job (S,Y,R,F,A...) y, al terminar, la lista (spool)
*   GET  /zztrad/result?id=ZT...      -> TSV exportado (UTF-8)
*   GET  /zztrad/delete?id=ZT...      -> borra los datos de INDX(ZT)
*
* Solo acepta pedidos desde la misma maquina (127.0.0.1 / ::1) y solo
* programas ZTRAD_*. Sintaxis compatible con SAP_BASIS 731.
*----------------------------------------------------------------------*
CLASS zcl_ztrad_http DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_http_extension .
  PRIVATE SECTION.
    DATA mo_server TYPE REF TO if_http_server .

    METHODS reply
      IMPORTING
        !iv_code TYPE i
        !iv_text TYPE string
        !iv_ctype TYPE string DEFAULT 'text/plain; charset=utf-8' .
    METHODS fld
      IMPORTING
        !iv_name TYPE string
      RETURNING
        value(rv_val) TYPE string .
    METHODS do_run .
    METHODS do_status .
    METHODS do_result .
    METHODS do_delete .
ENDCLASS.



CLASS zcl_ztrad_http IMPLEMENTATION.


  METHOD if_http_extension~handle_request.
    DATA: lv_addr TYPE string,
          lv_path TYPE string.

    mo_server = server.

    lv_addr = server->request->get_header_field( '~remote_addr' ).
    IF lv_addr <> '127.0.0.1' AND lv_addr <> '::1'.
      reply( iv_code = 403 iv_text = `forbidden ` && lv_addr ).
      RETURN.
    ENDIF.

    lv_path = server->request->get_header_field( '~path_info' ).
    TRANSLATE lv_path TO LOWER CASE.

    CASE lv_path.
      WHEN '' OR '/' OR '/ping'.
        reply( iv_code = 200
               iv_text = `ok sid=` && sy-sysid && ` client=` && sy-mandt
                      && ` user=` && sy-uname ).
      WHEN '/run'.
        do_run( ).
      WHEN '/status'.
        do_status( ).
      WHEN '/result'.
        do_result( ).
      WHEN '/delete'.
        do_delete( ).
      WHEN OTHERS.
        reply( iv_code = 404 iv_text = `unknown path ` && lv_path ).
    ENDCASE.
  ENDMETHOD.


  METHOD reply.
    DATA: lv_x    TYPE xstring,
          lv_code TYPE i.
    lv_code = iv_code.
    mo_server->response->set_status( code = lv_code reason = '' ).
    mo_server->response->set_header_field( name  = 'Content-Type'
                                          value = iv_ctype ).
    lv_x = cl_abap_codepage=>convert_to( source   = iv_text
                                         codepage = 'UTF-8' ).
    mo_server->response->set_data( lv_x ).
  ENDMETHOD.


  METHOD fld.
    rv_val = mo_server->request->get_form_field( iv_name ).
  ENDMETHOD.


  METHOD do_run.
    DATA: lt_f       TYPE tihttpnvp,
          ls_f       TYPE ihttpnvp,
          lt_par     TYPE STANDARD TABLE OF rsparams,
          ls_par     TYPE rsparams,
          lv_prog    TYPE progname,
          lv_name    TYPE string,
          lv_jobname TYPE tbtcjob-jobname VALUE 'ZTRAD_HTTP',
          lv_count   TYPE tbtcjob-jobcount,
          lv_id      TYPE indx-srtfd,
          lv_x       TYPE xstring,
          lv_body    TYPE string,
          lv_bom     TYPE string,
          lt_file    TYPE STANDARD TABLE OF string,
          lv_lines   TYPE i,
          lv_lstr    TYPE string,
          ls_pri     TYPE pri_params,
          lv_valid   TYPE c.

*   Programa: solo ZTRAD_* existentes
    lv_name = fld( 'prog' ).
    TRANSLATE lv_name TO UPPER CASE.
    lv_prog = lv_name.
    IF lv_prog(6) <> 'ZTRAD_'.
      reply( iv_code = 400 iv_text = `prog must be ZTRAD_*` ).
      RETURN.
    ENDIF.
    SELECT SINGLE name FROM trdir INTO lv_prog WHERE name = lv_prog.
    IF sy-subrc <> 0.
      reply( iv_code = 400 iv_text = `prog not found ` && lv_name ).
      RETURN.
    ENDIF.

*   Parametros de seleccion desde el query string
    mo_server->request->get_form_fields( CHANGING fields = lt_f ).
    LOOP AT lt_f INTO ls_f.
      lv_name = ls_f-name.
      TRANSLATE lv_name TO UPPER CASE.
      IF lv_name = 'PROG' OR lv_name = 'P_MEM'.
        CONTINUE.
      ENDIF.
      CLEAR ls_par.
      ls_par-selname = lv_name.
      ls_par-low     = ls_f-value.
      IF strlen( lv_name ) > 2 AND lv_name(2) = 'S_'.
        ls_par-kind = 'S'.
        ls_par-sign = 'I'.
        IF ls_f-value CA '*+'.
          ls_par-option = 'CP'.
        ELSE.
          ls_par-option = 'EQ'.
        ENDIF.
      ELSEIF strlen( lv_name ) > 2
         AND ( lv_name(2) = 'P_' OR lv_name(2) = 'R_' ).
        ls_par-kind = 'P'.
      ELSE.
        CONTINUE.
      ENDIF.
      APPEND ls_par TO lt_par.
    ENDLOOP.

*   Job
    CALL FUNCTION 'JOB_OPEN'
      EXPORTING
        jobname          = lv_jobname
      IMPORTING
        jobcount         = lv_count
      EXCEPTIONS
        OTHERS           = 1.
    IF sy-subrc <> 0.
      reply( iv_code = 500 iv_text = `JOB_OPEN failed` ).
      RETURN.
    ENDIF.

    CONCATENATE 'ZT' lv_count sy-uzeit INTO lv_id.

*   Cuerpo (TSV UTF-8) -> INDX(ZT)
    lv_x = mo_server->request->get_data( ).
    IF lv_x IS NOT INITIAL.
      lv_body = cl_abap_codepage=>convert_from( source   = lv_x
                                                codepage = 'UTF-8' ).
      lv_bom = cl_abap_conv_in_ce=>uccp( 'FEFF' ).
      IF strlen( lv_body ) > 0 AND lv_body(1) = lv_bom.
        SHIFT lv_body LEFT BY 1 PLACES.
      ENDIF.
      SPLIT lv_body AT cl_abap_char_utilities=>newline INTO TABLE lt_file.
      EXPORT data = lt_file TO DATABASE indx(zt) ID lv_id.
      DESCRIBE TABLE lt_file LINES lv_lines.
    ENDIF.

    CLEAR ls_par.
    ls_par-selname = 'P_MEM'.
    ls_par-kind    = 'P'.
    ls_par-low     = lv_id.
    APPEND ls_par TO lt_par.

    COMMIT WORK.

    CALL FUNCTION 'GET_PRINT_PARAMETERS'
      EXPORTING
        destination    = 'LOCL'
        immediately    = space
        release        = space
        new_list_id    = 'X'
        line_size      = 255
        line_count     = 65
        no_dialog      = 'X'
      IMPORTING
        out_parameters = ls_pri
        valid          = lv_valid
      EXCEPTIONS
        OTHERS         = 1.

    SUBMIT (lv_prog) WITH SELECTION-TABLE lt_par
      TO SAP-SPOOL SPOOL PARAMETERS ls_pri WITHOUT SPOOL DYNPRO
      VIA JOB lv_jobname NUMBER lv_count
      AND RETURN.
    IF sy-subrc <> 0.
      reply( iv_code = 500 iv_text = `SUBMIT failed` ).
      RETURN.
    ENDIF.

    CALL FUNCTION 'JOB_CLOSE'
      EXPORTING
        jobcount  = lv_count
        jobname   = lv_jobname
        strtimmed = 'X'
      EXCEPTIONS
        OTHERS    = 1.
    IF sy-subrc <> 0.
      reply( iv_code = 500 iv_text = `JOB_CLOSE failed count=` && lv_count ).
      RETURN.
    ENDIF.

    lv_lstr = lv_lines.
    CONDENSE lv_lstr.
    reply( iv_code = 200
           iv_text = `job=` && lv_jobname
                  && cl_abap_char_utilities=>cr_lf && `count=` && lv_count
                  && cl_abap_char_utilities=>cr_lf && `id=` && lv_id
                  && cl_abap_char_utilities=>cr_lf && `lines=` && lv_lstr ).
  ENDMETHOD.


  METHOD do_status.
    DATA: lv_job   TYPE tbtcjob-jobname,
          lv_count TYPE tbtcjob-jobcount,
          lv_st    TYPE tbtco-status,
          lv_list  TYPE tbtcp-listident,
          lv_rq    TYPE tsp01-rqident,
          lt_buf   TYPE STANDARD TABLE OF soli,
          ls_buf   TYPE soli,
          lt_log   TYPE STANDARD TABLE OF tbtc5,
          ls_log   TYPE tbtc5,
          lv_out   TYPE string,
          lv_s     TYPE string,
          lv_nl    TYPE string.

    lv_nl = cl_abap_char_utilities=>cr_lf.
    lv_s = fld( 'job' ).
    TRANSLATE lv_s TO UPPER CASE.
    lv_job = lv_s.
    lv_s = fld( 'count' ).
    lv_count = lv_s.

    SELECT SINGLE status FROM tbtco INTO lv_st
      WHERE jobname = lv_job AND jobcount = lv_count.
    IF sy-subrc <> 0.
      reply( iv_code = 404 iv_text = `job not found` ).
      RETURN.
    ENDIF.
    lv_out = `status=` && lv_st.

    IF lv_st = 'F' OR lv_st = 'A'.
      SELECT SINGLE listident FROM tbtcp INTO lv_list
        WHERE jobname = lv_job AND jobcount = lv_count AND stepcount = 1.
      IF sy-subrc = 0 AND lv_list IS NOT INITIAL.
        lv_rq = lv_list.
        lv_s = lv_rq.
        CONDENSE lv_s.
        lv_out = lv_out && lv_nl && `spool=` && lv_s && lv_nl && `--- list`.
        CALL FUNCTION 'RSPO_RETURN_ABAP_SPOOLJOB'
          EXPORTING
            rqident = lv_rq
          TABLES
            buffer  = lt_buf
          EXCEPTIONS
            OTHERS  = 1.
        LOOP AT lt_buf INTO ls_buf.
          lv_s = ls_buf-line.
          lv_out = lv_out && lv_nl && lv_s.
        ENDLOOP.
      ENDIF.
      IF lv_st = 'A'.
        CALL FUNCTION 'BP_JOBLOG_READ'
          EXPORTING
            jobcount  = lv_count
            jobname   = lv_job
          TABLES
            joblogtbl = lt_log
          EXCEPTIONS
            OTHERS    = 1.
        lv_out = lv_out && lv_nl && `--- joblog`.
        LOOP AT lt_log INTO ls_log.
          lv_s = ls_log-text.
          lv_out = lv_out && lv_nl && lv_s.
        ENDLOOP.
      ENDIF.
    ENDIF.

    reply( iv_code = 200 iv_text = lv_out ).
  ENDMETHOD.


  METHOD do_result.
    DATA: lv_s    TYPE string,
          lv_id   TYPE indx-srtfd,
          lt_file TYPE STANDARD TABLE OF string,
          lv_row  TYPE string,
          lv_out  TYPE string.

    lv_s = fld( 'id' ).
    TRANSLATE lv_s TO UPPER CASE.
    lv_id = lv_s.
    IMPORT data = lt_file FROM DATABASE indx(zt) ID lv_id.
    IF sy-subrc <> 0.
      reply( iv_code = 404 iv_text = `no data for id` ).
      RETURN.
    ENDIF.
    LOOP AT lt_file INTO lv_row.
      IF sy-tabix > 1.
        lv_out = lv_out && cl_abap_char_utilities=>cr_lf.
      ENDIF.
      lv_out = lv_out && lv_row.
    ENDLOOP.
    reply( iv_code  = 200
           iv_text  = lv_out
           iv_ctype = 'text/tab-separated-values; charset=utf-8' ).
  ENDMETHOD.


  METHOD do_delete.
    DATA: lv_s  TYPE string,
          lv_id TYPE indx-srtfd.

    lv_s = fld( 'id' ).
    TRANSLATE lv_s TO UPPER CASE.
    lv_id = lv_s.
    IF lv_id(2) <> 'ZT'.
      reply( iv_code = 400 iv_text = `bad id` ).
      RETURN.
    ENDIF.
    DELETE FROM DATABASE indx(zt) ID lv_id.
    COMMIT WORK.
    reply( iv_code = 200 iv_text = `deleted` ).
  ENDMETHOD.
ENDCLASS.
