*----------------------------------------------------------------------*
***INCLUDE ZMG_FEEDBACK_STATUS_0100O01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0100 OUTPUT.
  GET TIME STAMP FIELD lv_finish.
  ls_timestamp-finish_timestamp = lv_finish.
  ls_timestamp-finish_screen = 'Log In Screen'.
  IF lv_start IS NOT INITIAL.
    ls_timestamp-result = cl_abap_tstmp=>subtract(
                    tstmp1 = lv_finish                 " UTC Time Stamp
                    tstmp2 = lv_start                 " UTC Time Stamp
                  ) .
  ENDIF.
  ls_timestamp-result = ls_timestamp-result * 1000.
  APPEND ls_timestamp TO lt_timestamp.
  lo_feedback = NEW zmg_cl_feedback( ).
  p_password = ''.
  p_email = ''.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_0200 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0200 OUTPUT.
* SET PF-STATUS 'xxxxxxxx'.
* SET TITLEBAR 'xxx'.

  p_username = ls_user-username.
  p_first_name = ls_user-firstname.
  p_last_name = ls_user-lastname.
  p_team_id = ls_user-teamid.
  lo_team->get_team_name(
      IMPORTING
        ev_team_name = p_team                 " Team Name Data Element
    ).
  IF lo_container_team IS INITIAL.
    CREATE OBJECT lo_container_team
      EXPORTING
        container_name = 'MY_TEAM_CONTAINER'.    " Name of the Screen CustCtrl Name to Link Container To
    CREATE OBJECT lo_alv_my_team
      EXPORTING
        i_parent = lo_container_team.                 " Parent Container

    CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
      EXPORTING
        i_structure_name   = 'ZMG_S_MY_TEAM'
        i_internal_tabname = 'lt_my_team'
      CHANGING
        ct_fieldcat        = lt_fcat_my_team.
  ENDIF.

  ls_layout-col_opt = abap_true.
  ls_layout-sel_mode = ''.
  lo_user->build_the_team(
   IMPORTING et_team = lt_team
      ).
  MOVE-CORRESPONDING lt_team TO lt_my_team.
  lo_alv_my_team->set_table_for_first_display(
    EXPORTING
      i_save                        = 'A'                 " Save Layout
      is_layout                     = ls_layout                 " Layout
    CHANGING
      it_outtab                     = lt_my_team                 " Output Table
      it_fieldcatalog               = lt_fcat_my_team                 " Field Catalog
  ).

  IF lo_container_feedback IS INITIAL.
    CREATE OBJECT lo_container_feedback
      EXPORTING
        container_name = 'ALL_FEEDBACK_CONTAINER'.

    CREATE OBJECT lo_alv_my_feedback
      EXPORTING
        i_parent = lo_container_feedback.                 " Parent Container


    CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
      EXPORTING
        i_structure_name   = 'ZMG_S_MY_FEEDBACK'
        i_internal_tabname = 'lt_all_feedback'
      CHANGING
        ct_fieldcat        = lt_fcat_all_feedback.
  ENDIF.
  ls_layout-sel_mode = 'A'.
  lo_feedback->get_my_request(
    EXPORTING
      is_user        = ls_user                 " User Structure
    IMPORTING
      et_my_feedback = lt_all_feedback
  ).
  lo_alv_my_feedback->set_table_for_first_display(
    EXPORTING
      i_save                        = 'A'                 " Save Layout
      is_layout                     = ls_layout                 " Layout
    CHANGING
      it_outtab                     = lt_all_feedback                 " Output Table
      it_fieldcatalog               = lt_fcat_all_feedback                " Field Catalog
  ).
  GET TIME STAMP FIELD lv_finish.
  ls_timestamp-finish_timestamp = lv_finish.
  ls_timestamp-finish_screen = 'Manager Screen'.
  ls_timestamp-result = cl_abap_tstmp=>subtract(
                          tstmp1 = lv_finish                 " UTC Time Stamp
                          tstmp2 = lv_start                 " UTC Time Stamp
                        ) .
  ls_timestamp-result = ls_timestamp-result * 1000.
  APPEND ls_timestamp TO lt_timestamp.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_0300 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0300 OUTPUT.
* SET PF-STATUS 'xxxxxxxx'.
* SET TITLEBAR 'xxx'.

  p_email_user = ls_user-email.
  p_username = ls_user-username.
  p_first_name = ls_user-firstname.
  p_last_name = ls_user-lastname.

  IF lo_container_team IS INITIAL.
    CREATE OBJECT lo_container_team
      EXPORTING
        container_name = 'MY_TEAM_CONTAINER'.    " Name of the Screen CustCtrl Name to Link Container To
    CREATE OBJECT lo_alv_my_team
      EXPORTING
        i_parent = lo_container_team.                 " Parent Container
  ENDIF.
  CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
    EXPORTING
      i_structure_name   = 'ZMG_S_MY_TEAM'
      i_internal_tabname = 'lt_my_team'
    CHANGING
      ct_fieldcat        = lt_fcat_my_team.

  ls_layout-col_opt = abap_true.

  lo_user->build_the_team(
   IMPORTING et_team = lt_team
      ).
  MOVE-CORRESPONDING lt_team TO lt_my_team.
  lo_alv_my_team->set_table_for_first_display(
    EXPORTING
      i_save                        = 'A'                 " Save Layout
      is_layout                     = ls_layout                 " Layout
    CHANGING
      it_outtab                     = lt_my_team                 " Output Table
      it_fieldcatalog               = lt_fcat_my_team                 " Field Catalog
  ).

  IF lo_container_feedback IS INITIAL.
    CREATE OBJECT lo_container_feedback
      EXPORTING
        container_name = 'MY_FEEDBACK_CONTAINER'.

    CREATE OBJECT lo_alv_my_feedback
      EXPORTING
        i_parent = lo_container_feedback.                 " Parent Container
  ENDIF.

  CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
    EXPORTING
      i_structure_name   = 'ZMG_S_MY_FEEDBACK'
      i_internal_tabname = 'lt_my_feedback'
    CHANGING
      ct_fieldcat        = lt_fcat_my_feedback.

  ls_layout-sel_mode = 'D'.

  lo_feedback->get_my_request(
    EXPORTING
      is_user        = ls_user                 " User Structure
    IMPORTING
      et_my_feedback = lt_my_feedback
  ).
  lo_alv_my_feedback->set_table_for_first_display(
    EXPORTING
      i_save                        = 'A'                 " Save Layout
      is_layout                     = ls_layout                 " Layout
    CHANGING
      it_outtab                     = lt_my_feedback                 " Output Table
      it_fieldcatalog               = lt_fcat_my_feedback                " Field Catalog
  ).
  GET TIME STAMP FIELD lv_finish.
  ls_timestamp-finish_timestamp = lv_finish.
  ls_timestamp-finish_screen = 'User Screen'.
  ls_timestamp-result = cl_abap_tstmp=>subtract(
                          tstmp1 = lv_finish                 " UTC Time Stamp
                          tstmp2 = lv_start                 " UTC Time Stamp
                        ) .
  ls_timestamp-result = ls_timestamp-result * 1000.
  APPEND ls_timestamp TO lt_timestamp.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_0500 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0500 OUTPUT.
* SET PF-STATUS 'xxxxxxxx'.
* SET TITLEBAR 'xxx'.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_0900 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0900 OUTPUT.
  CLEAR: rb_exp_1, rb_exp_2, rb_exp_3, rb_exp_4, rb_exp_5.
  CLEAR: rb_lead_1, rb_lead_2, rb_lead_3, rb_lead_4, rb_lead_5.
  CLEAR: rb_netw_1, rb_netw_2, rb_netw_3, rb_netw_4, rb_netw_5.
  CLEAR: rb_team_1, rb_team_2, rb_team_3, rb_team_4, rb_team_5.

  LOOP AT SCREEN.
    IF ls_user-role = zmg_if_constans=>sc_user_role-developer.
      IF screen-name = 'BTN_SAVE_FEEDBACK' OR screen-name = 'BTN_COPLETE_FEEDBACK'.
        screen-active = 0.
        MODIFY SCREEN.
      ENDIF.
    ENDIF.
  ENDLOOP.

  lo_feedback->get_current_feedback(
    IMPORTING
      es_current_feedback = ls_current_fb                 " Feedback Structure
  ).

  p_type_of_request = ls_current_fb-type.
  p_requestor_username = ls_current_fb-requestor_name.

  IF ls_current_fb-status = zmg_if_constans=>sc_feedback_status-completed.
    lv_read_only = abap_true.
  ELSE.
    lv_read_only = abap_false.
  ENDIF.
  IF ls_user-role = zmg_if_constans=>sc_user_role-developer.
    lv_read_only = abap_true.
  ENDIF.
  IF lo_cc_exp IS INITIAL.
    CREATE OBJECT lo_cc_exp
      EXPORTING
        container_name = 'CC_EXP'.                " Name of the Screen CustCtrl Name to Link Container To
    CREATE OBJECT lo_txt_exp
      EXPORTING
        parent = lo_cc_exp.                       " Parent Container
  ENDIF.

  lo_feedback->call_container(
    io_container = lo_cc_exp                 " Container for custom controls in the dynpro area
    io_text_edit = lo_txt_exp                 " Container for custom controls in the dynpro area
    iv_text      = ls_current_fb-message_exp                 " Message
    iv_read_only = lv_read_only
  ).

  IF lo_cc_lead IS INITIAL.
    CREATE OBJECT lo_cc_lead
      EXPORTING
        container_name = 'CC_LEAD'.                " Name of the Screen CustCtrl Name to Link Container To
    CREATE OBJECT lo_txt_lead
      EXPORTING
        parent = lo_cc_lead.                       " Parent Container
  ENDIF.

  lo_feedback->call_container(
    io_container = lo_cc_lead                 " Container for custom controls in the dynpro area
    io_text_edit = lo_txt_lead                 " Container for custom controls in the dynpro area
    iv_text      = ls_current_fb-message_leader                 " Message
    iv_read_only = lv_read_only
  ).

  IF lo_cc_netw IS INITIAL.
    CREATE OBJECT lo_cc_netw
      EXPORTING
        container_name = 'CC_NETW'.                " Name of the Screen CustCtrl Name to Link Container To
    CREATE OBJECT lo_txt_netw
      EXPORTING
        parent = lo_cc_netw.                       " Parent Container
  ENDIF.

  lo_feedback->call_container(
   io_container = lo_cc_netw                 " Container for custom controls in the dynpro area
   io_text_edit = lo_txt_netw                 " Container for custom controls in the dynpro area
   iv_text      = ls_current_fb-message_netw                 " Message
   iv_read_only = lv_read_only
 ).

  IF lo_cc_team IS INITIAL.
    CREATE OBJECT lo_cc_team
      EXPORTING
        container_name = 'CC_TEAM'.                " Name of the Screen CustCtrl Name to Link Container To
    CREATE OBJECT lo_txt_team
      EXPORTING
        parent = lo_cc_team.                       " Parent Container
  ENDIF.

  lo_feedback->call_container(
   io_container = lo_cc_team                 " Container for custom controls in the dynpro area
   io_text_edit = lo_txt_team                 " Container for custom controls in the dynpro area
   iv_text      = ls_current_fb-message_team                 " Message
   iv_read_only = lv_read_only
 ).
  CASE ls_current_fb-grade_exp.
    WHEN 1.
      rb_exp_1 = 'X'.
    WHEN 2.
      rb_exp_2 = 'X'.
    WHEN 3.
      rb_exp_3 = 'X'.
    WHEN 4.
      rb_exp_4 = 'X'.
    WHEN 5.
      rb_exp_5 = 'X'.
  ENDCASE.

  CASE ls_current_fb-grade_leader.
    WHEN 1.
      rb_lead_1 = 'X'.
    WHEN 2.
      rb_lead_2 = 'X'.
    WHEN 3.
      rb_lead_3 = 'X'.
    WHEN 4.
      rb_lead_4 = 'X'.
    WHEN 5.
      rb_lead_5 = 'X'.
  ENDCASE.

  CASE ls_current_fb-grade_netw.
    WHEN 1.
      rb_netw_1 = 'X'.
    WHEN 2.
      rb_netw_2 = 'X'.
    WHEN 3.
      rb_netw_3 = 'X'.
    WHEN 4.
      rb_netw_4 = 'X'.
    WHEN 5.
      rb_netw_5 = 'X'.
  ENDCASE.

  CASE ls_current_fb-grade_team.
    WHEN 1.
      rb_team_1 = 'X'.
    WHEN 2.
      rb_team_2 = 'X'.
    WHEN 3.
      rb_team_3 = 'X'.
    WHEN 4.
      rb_team_4 = 'X'.
    WHEN 5.
      rb_team_5 = 'X'.
  ENDCASE.

  GET TIME STAMP FIELD lv_finish.
  ls_timestamp-finish_timestamp = lv_finish.
  ls_timestamp-finish_screen = 'Feedback Screen'.
  ls_timestamp-result = cl_abap_tstmp=>subtract(
                          tstmp1 = lv_finish                 " UTC Time Stamp
                          tstmp2 = lv_start                 " UTC Time Stamp
                        ) .
  ls_timestamp-result = ls_timestamp-result * 1000.
  APPEND ls_timestamp TO lt_timestamp.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_1000 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_1000 OUTPUT.
* SET PF-STATUS 'xxxxxxxx'.
* SET TITLEBAR 'xxx'.
  LOOP AT SCREEN.
    IF screen-name = 'P_CURRENT_PASSWORD'
    OR screen-name = 'P_NEW_PASSWORD'
    OR screen-name = 'P_R_PASSWORD'.
      screen-input = '1'.     "1 = editable, 0 = display only
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.

  CLEAR: p_current_password, p_new_password, p_r_password.

ENDMODULE.
