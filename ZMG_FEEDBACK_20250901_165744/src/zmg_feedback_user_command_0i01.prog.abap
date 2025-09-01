*----------------------------------------------------------------------*
***INCLUDE ZMG_FEEDBACK_USER_COMMAND_0I01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.

  IF sy-ucomm = 'CONTINUE'.
    SELECT * FROM zmg_users
      INTO CORRESPONDING FIELDS OF ls_user
      WHERE  email = p_email AND password = p_password.
    ENDSELECT.
    IF ls_user IS NOT INITIAL.
      lo_user = NEW zmg_cl_user( is_user = ls_user ).
      lo_team = NEW zmg_cl_team( is_user = ls_user ).
    ELSE.
      MESSAGE 'Email or password are incorect' TYPE 'S'.
    ENDIF.
    IF ls_user-first_password = abap_true.
      CALL SCREEN '1000' STARTING AT 1 20
                         ENDING AT  70 80.
    ENDIF.
    IF ls_user-role = zmg_if_constans=>sc_user_role-developer.
      CALL SCREEN '300'.
    ELSEIF ls_user-role = zmg_if_constans=>sc_user_role-manager.
      CALL SCREEN '200'.
    ENDIF.
  ENDIF.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0300  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0300 INPUT.
  CASE sy-ucomm.
    WHEN 'REQUEST_FEEDBACK'.
      CALL SCREEN '0400'.
    WHEN 'MFEEDBACK'.
      CONCATENATE sy-datum+0(4) '0630' INTO DATA(lv_mid_year).
      IF sy-datum <= lv_mid_year .
        lo_feedback->request_manager_feedback(
          io_user          = lo_user                 " User Class
          iv_feedback_type = zmg_if_constans=>sc_feedback_type-my_year_reviw                 " Feedback Type
        ).
      ELSE.
        lo_feedback->request_manager_feedback(
          io_user          = lo_user                 " User Class
          iv_feedback_type = zmg_if_constans=>sc_feedback_type-final_year_review                 " Feedback Type
        ).
      ENDIF.
    WHEN 'L_OUT'.
      CALL SCREEN '0100'.
    when 'OFEEDBACK'.
      lo_alv_my_feedback->get_selected_rows(
        IMPORTING
          et_index_rows = lt_index                 " Indexes of Selected Rows
      ).
      IF lt_index IS NOT INITIAL.
        READ TABLE lt_my_feedback INDEX lt_index[ 1 ] ASSIGNING <fs_selected_feedback>.
        lo_feedback->set_current_feedback( iv_feedback_id = <fs_selected_feedback>-feedback_id ).
        CALL SCREEN '0900'.
      ELSE.
        MESSAGE 'No request selected' TYPE 'W'.
      ENDIF.
  ENDCASE.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0400  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0400 INPUT.

  CASE sy-ucomm.
    WHEN '' .
      SELECT SINGLE * FROM zmg_projects
        INTO CORRESPONDING FIELDS OF ls_project
        WHERE project_id = p_project_id.
      p_project_name = ls_project-project_name.
    WHEN 'SEND_REQUEST'.
      lo_feedback = NEW zmg_cl_feedback( ).
      lo_feedback->request_peg_feedback(
       is_user         = ls_user                 " User Structure
       is_project      = ls_project                 " Project Structure
       iv_anonymity    = cb_anonymity                 " Project Structure
       iv_request_type = zmg_if_constans=>sc_feedback_type-project_evaluation                 " Feedback Type
       io_user         = lo_user                 " User Class
     ).
      CALL SCREEN '0300'.
    WHEN 'GO_BACK'.
      CALL SCREEN '0300'.
  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0200  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0200 INPUT.
  CASE sy-ucomm.
    WHEN 'ADD_USER'.
      lv_screen = '0500'.
    WHEN 'ADD_TEAM'.
      lv_screen = '0600'.
    WHEN 'ADD_TO_PROJECT'.
      lv_screen = '0700'.
    WHEN 'ADD_TO_TEAM'.
      lv_screen = '0800'.
    WHEN 'RESPONDFEEDBACK'.
      lo_alv_my_feedback->get_selected_rows(
        IMPORTING
          et_index_rows = lt_index                 " Indexes of Selected Rows
      ).
      IF lt_index IS NOT INITIAL.
        READ TABLE lt_all_feedback INDEX lt_index[ 1 ] ASSIGNING <fs_selected_feedback>.
        lo_feedback->set_current_feedback( iv_feedback_id = <fs_selected_feedback>-feedback_id ).
        CALL SCREEN '0900'.
      ELSE.
        MESSAGE 'No request selected' TYPE 'W'.
      ENDIF.
    WHEN 'L_OUT'.
      CALL SCREEN '0100'.
  ENDCASE.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0500  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0500 INPUT.
  CASE sy-ucomm.
    WHEN 'CUSER'.
      ls_new_user-username = p_new_username.
      ls_new_user-firstname = p_new_f_name.
      ls_new_user-lastname = p_new_l_name.
      ls_new_user-email = p_new_email.
      ls_new_user-role = p_assigne_role.
      ls_new_user-password = p_temporary_password.

      lo_user->create_user( is_new_user = ls_new_user ).
      CALL SCREEN '0200'.
  ENDCASE.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0600  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0600 INPUT.
  CASE sy-ucomm.
    WHEN 'CTEAM'.
      lo_team->create_team(
        iv_team_name    = p_team_name                 " Team Name Data Element
        iv_team_manager = p_manager_id                 " Manager ID Data Element
      ).
      CALL SCREEN '0200'.
  ENDCASE.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0700  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0700 INPUT.
  CASE sy-ucomm.
    WHEN 'ADD_TO_PROJECT'.
      IF lo_project IS INITIAL.
        lo_project = NEW zmg_cl_project( ).
      ENDIF.
      lo_project->add_user_to_project(
      io_user       = lo_user                 " User Class
      is_user_name  = p_user_name                 " Username Data Element
      iv_project_id = p_projectid                 " Project ID
    ).
      CALL SCREEN '0200'.
  ENDCASE.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0800  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0800 INPUT.
  CASE sy-ucomm.
    WHEN 'ADD_TO_TEAM'.
      lo_user->add_user_to_team(
        iv_username = p_add_user                 " Username Data Element
        iv_team_id  = p_add_team_id                 " Team ID Data Element
      ).
      CALL SCREEN '0200'.
  ENDCASE.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0900  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0900 INPUT.

  CASE sy-ucomm.
    WHEN 'SFEEDBACK' OR 'GO_BACK'.

      lo_txt_exp->get_text_as_stream(
        IMPORTING
          text  =  lt_txt_exp               " text as stream with carrige retruns and linefeeds
          ).
      lo_txt_lead->get_text_as_stream(
        IMPORTING
          text  =  lt_txt_lead               " text as stream with carrige retruns and linefeeds
           ).

      lo_txt_netw->get_text_as_stream(
        IMPORTING
          text  =  lt_txt_netw               " text as stream with carrige retruns and linefeeds
            ).

      lo_txt_team->get_text_as_stream(
        IMPORTING
          text  =  lt_txt_team               " text as stream with carrige retruns and linefeeds
           ).

      IF lines( lt_txt_exp ) > 1 .
        MESSAGE 'The Experience Feedback is too long' TYPE 'E'.
        lv_too_long = abap_true.
      ENDIF.
      IF lines( lt_txt_lead ) > 1.
        MESSAGE 'The Leadership Feedback is too long' TYPE 'E'.
        lv_too_long = abap_true.
      ENDIF.
      IF lines( lt_txt_netw ) > 1.
        MESSAGE 'The Networking Feedback is too long' TYPE 'E'.
        lv_too_long = abap_true.
      ENDIF.
      IF lines( lt_txt_team ) > 1.
        MESSAGE 'The Team Feedback is too long' TYPE 'E'.
        lv_too_long = abap_true.
      ENDIF.

      IF rb_exp_1 EQ 'X'.
        lv_exp_grade = 1.
      ELSEIF rb_exp_2 EQ 'X'.
        lv_exp_grade = 2.
      ELSEIF rb_exp_3 EQ 'X'.
        lv_exp_grade = 3.
      ELSEIF rb_exp_4 EQ 'X'.
        lv_exp_grade = 4.
      ELSEIF rb_exp_5 EQ 'X'.
        lv_exp_grade = 5.
      ENDIF.

      IF rb_netw_1 EQ 'X'.
        lv_netw_grade = 1.
      ELSEIF rb_netw_2 EQ 'X'.
        lv_netw_grade = 2.
      ELSEIF rb_netw_3 EQ 'X'.
        lv_netw_grade = 3.
      ELSEIF rb_netw_4 EQ 'X'.
        lv_netw_grade = 4.
      ELSEIF rb_netw_5 EQ 'X'.
        lv_netw_grade = 5.
      ENDIF.

      IF rb_team_1 EQ 'X'.
        lv_team_grade = 1.
      ELSEIF rb_team_2 EQ 'X'.
        lv_team_grade = 2.
      ELSEIF rb_team_3 EQ 'X'.
        lv_team_grade = 3.
      ELSEIF rb_team_4 EQ 'X'.
        lv_team_grade = 4.
      ELSEIF rb_team_5 EQ 'X'.
        lv_team_grade = 5.
      ENDIF.

      IF rb_lead_1 EQ 'X'.
        lv_lead_grade = 1.
      ELSEIF rb_lead_2 EQ 'X'.
        lv_lead_grade = 2.
      ELSEIF rb_lead_3 EQ 'X'.
        lv_lead_grade = 3.
      ELSEIF rb_lead_4 EQ 'X'.
        lv_lead_grade = 4.
      ELSEIF rb_lead_5 EQ 'X'.
        lv_lead_grade = 5.
      ENDIF.

      IF lv_too_long NE abap_true.
        lo_feedback->update_feedback(
          it_text_exp   = lt_txt_exp
          it_text_netw  = lt_txt_netw
          it_text_team  = lt_txt_team
          it_text_lead  = lt_txt_lead
          iv_exp_grade  = lv_exp_grade                  " Grade for Experience Level
          iv_netw_grade = lv_netw_grade                 " Grade for Networking Skills
          iv_team_grade = lv_team_grade                 " Grade for Teamwork skills
          iv_lead_grade = lv_lead_grade                 " Grade for Leadership Skills
          iv_status = zmg_if_constans=>sc_feedback_status-opened
        ).
      ENDIF.
      IF sy-ucomm = 'GO_BACK'.
        CALL SCREEN '0200'.
      ENDIF.
    WHEN 'CFEEDBACK'.

      lo_txt_exp->get_text_as_stream(
        IMPORTING
          text  =  lt_txt_exp               " text as stream with carrige retruns and linefeeds
          ).
      lo_txt_lead->get_text_as_stream(
        IMPORTING
          text  =  lt_txt_lead               " text as stream with carrige retruns and linefeeds
           ).

      lo_txt_netw->get_text_as_stream(
        IMPORTING
          text  =  lt_txt_netw               " text as stream with carrige retruns and linefeeds
            ).

      lo_txt_team->get_text_as_stream(
        IMPORTING
          text  =  lt_txt_team               " text as stream with carrige retruns and linefeeds
           ).

      IF lines( lt_txt_exp ) > 1 .
        MESSAGE 'The Experience Feedback is too long' TYPE 'E'.
        lv_too_long = abap_true.
      ENDIF.
      IF lines( lt_txt_lead ) > 1.
        MESSAGE 'The Leadership Feedback is too long' TYPE 'E'.
        lv_too_long = abap_true.
      ENDIF.
      IF lines( lt_txt_netw ) > 1.
        MESSAGE 'The Networking Feedback is too long' TYPE 'E'.
        lv_too_long = abap_true.
      ENDIF.
      IF lines( lt_txt_team ) > 1.
        MESSAGE 'The Team Feedback is too long' TYPE 'E'.
        lv_too_long = abap_true.
      ENDIF.

      IF rb_exp_1 EQ 'X'.
        lv_exp_grade = 1.
      ELSEIF rb_exp_2 EQ 'X'.
        lv_exp_grade = 2.
      ELSEIF rb_exp_3 EQ 'X'.
        lv_exp_grade = 3.
      ELSEIF rb_exp_4 EQ 'X'.
        lv_exp_grade = 4.
      ELSEIF rb_exp_5 EQ 'X'.
        lv_exp_grade = 5.
      ENDIF.

      IF rb_netw_1 EQ 'X'.
        lv_netw_grade = 1.
      ELSEIF rb_netw_2 EQ 'X'.
        lv_netw_grade = 2.
      ELSEIF rb_netw_3 EQ 'X'.
        lv_netw_grade = 3.
      ELSEIF rb_netw_4 EQ 'X'.
        lv_netw_grade = 4.
      ELSEIF rb_netw_5 EQ 'X'.
        lv_netw_grade = 5.
      ENDIF.

      IF rb_team_1 EQ 'X'.
        lv_team_grade = 1.
      ELSEIF rb_team_2 EQ 'X'.
        lv_team_grade = 2.
      ELSEIF rb_team_3 EQ 'X'.
        lv_team_grade = 3.
      ELSEIF rb_team_4 EQ 'X'.
        lv_team_grade = 4.
      ELSEIF rb_team_5 EQ 'X'.
        lv_team_grade = 5.
      ENDIF.

      IF rb_lead_1 EQ 'X'.
        lv_lead_grade = 1.
      ELSEIF rb_lead_2 EQ 'X'.
        lv_lead_grade = 2.
      ELSEIF rb_lead_3 EQ 'X'.
        lv_lead_grade = 3.
      ELSEIF rb_lead_4 EQ 'X'.
        lv_lead_grade = 4.
      ELSEIF rb_lead_5 EQ 'X'.
        lv_lead_grade = 5.
      ENDIF.

      IF lv_too_long NE abap_true.
        lo_feedback->update_feedback(
          it_text_exp   = lt_txt_exp
          it_text_netw  = lt_txt_netw
          it_text_team  = lt_txt_team
          it_text_lead  = lt_txt_lead
          iv_exp_grade  = lv_exp_grade                  " Grade for Experience Level
          iv_netw_grade = lv_netw_grade                 " Grade for Networking Skills
          iv_team_grade = lv_team_grade                 " Grade for Teamwork skills
          iv_lead_grade = lv_lead_grade                 " Grade for Leadership Skills
          iv_status = zmg_if_constans=>sc_feedback_status-completed
        ).
      ENDIF.
      CALL SCREEN '0200'.
  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_1000  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_1000 INPUT.
  CASE sy-ucomm.
    WHEN 'CNG_PASSWORD'.
      IF p_current_password = ls_user-password AND p_new_password = p_r_password AND p_current_password <> p_new_password.
        lo_user->change_password(
          is_user         = ls_user                 " User Structure
          iv_new_password = p_new_password                 " User Password Data Element
        ).
        LEAVE TO SCREEN 0.
      ELSEIF p_current_password = p_new_password.
        MESSAGE 'Current passowrd is the same as the new password' TYPE 'S'.
      ELSEIF p_new_password <> p_r_password.
        MESSAGE 'The new password is not the same as the reentered new password' TYPE 'S'.
      ELSEIF p_current_password <> ls_user-password.
        MESSAGE 'Current password is incorect' TYPE 'S'.
      ENDIF.
  ENDCASE.
ENDMODULE.
