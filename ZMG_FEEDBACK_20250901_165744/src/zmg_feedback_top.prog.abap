*&---------------------------------------------------------------------*
*& Include          ZMG_FEEDBACK_TOP
*&---------------------------------------------------------------------*
PROGRAM zmg_feedback.

DATA: lo_user               TYPE REF TO zmg_cl_user,
      lo_team               TYPE REF TO zmg_cl_team,
      lo_feedback           TYPE REF TO zmg_cl_feedback,
      lo_container_team     TYPE REF TO cl_gui_custom_container,
      lo_container_feedback TYPE REF TO cl_gui_custom_container,
      lo_alv_my_team        TYPE REF TO cl_gui_alv_grid,
      lo_alv_my_feedback    TYPE REF TO cl_gui_alv_grid,
      lo_project            TYPE REF TO zmg_cl_project,
      lo_cc_exp             TYPE REF TO cl_gui_custom_container,
      lo_txt_exp            TYPE REF TO cl_gui_textedit,
      lo_cc_netw            TYPE REF TO cl_gui_custom_container,
      lo_txt_netw           TYPE REF TO cl_gui_textedit,
      lo_cc_team            TYPE REF TO cl_gui_custom_container,
      lo_txt_team           TYPE REF TO cl_gui_textedit,
      lo_cc_lead            TYPE REF TO cl_gui_custom_container,
      lo_txt_lead           TYPE REF TO cl_gui_textedit,
      lv_start              TYPE timestampl,
      lv_finish             TYPE timestampl,
      ls_timestamp          TYPE zmg_s_time_stamp,
      lt_timestamp          TYPE TABLE OF zmg_s_time_stamp.

DATA: lt_index   TYPE lvc_t_row.
FIELD-SYMBOLS: <fs_selected_feedback> TYPE zmg_s_my_feedback.
" SCREEN 0100 Data ~ Log in screen
DATA: p_email    TYPE zmg_email_de,
      p_password TYPE zmg_password_de,
      ls_user    TYPE zmg_s_user,
      lt_user    TYPE TABLE OF zmg_s_user.


" SCREEN 0200 Data ~ Manager view screen
DATA: p_team_id    TYPE zmg_teamid_de,
      p_team       TYPE zmg_teamname_de,
      lv_screen(4) TYPE n VALUE '9999'.
" SCREEN 0300 Data ~ User view screen
DATA: lt_team              TYPE TABLE OF zmg_s_user,
      lt_my_team           TYPE TABLE OF zmg_s_my_team,
      ls_my_team           TYPE zmg_s_my_team,
      lt_fcat_my_team      TYPE lvc_t_fcat,
      lt_my_feedback       TYPE TABLE OF zmg_s_my_feedback,
      lt_all_feedback      TYPE TABLE OF zmg_s_my_feedback,
      lt_fcat_my_feedback  TYPE lvc_t_fcat,
      lt_fcat_all_feedback TYPE lvc_t_fcat,
      ls_layout            TYPE lvc_s_layo,
      ls_my_feedback       TYPE zmg_s_my_feedback,
      p_email_user         TYPE zmg_email_de,
      p_username           TYPE zmg_username_de,
      p_first_name         TYPE zmg_firstname_de,
      p_last_name          TYPE zmg_lastname_de.

" SCREEN 0400 Data ~ Request Feedback Screen

DATA: ls_project       TYPE zmg_s_project,
      p_project_id     TYPE zmg_projectid_de,
      p_project_name   TYPE zmg_projectname_de,
      p_request_type   TYPE zmg_fdbk_type_de,
      cb_anonymity     TYPE zmg_fdbk_anon_de,
      ls_projdev_dummy TYPE zmg_projsdev.

" SCREEN 0500 Data ~ Create User Screen

DATA: ls_new_user          TYPE zmg_s_user,
      p_new_username       TYPE zmg_username_de,
      p_new_f_name         TYPE zmg_firstname_de,
      p_new_l_name         TYPE zmg_lastname_de,
      p_new_email          TYPE zmg_email_de,
      p_assigne_role       TYPE zmg_role_de,
      p_temporary_password TYPE zmg_password_de,
      p_assign_team_id     TYPE zmg_teamid_de,
      lv_add_dummy         TYPE abap_bool.

" SCREEN 0600 Data ~ Create Team Screen

DATA: p_manager_id  TYPE zmg_managerid_de,
      p_team_name   TYPE zmg_teamname_de,
      ls_team_check TYPE zmg_teams,
      lv_exists     TYPE abap_bool.

" SCREEN 0700 Data ~ Add To Project Screen

DATA : p_user_name TYPE zmg_username_de,
       p_projectid TYPE zmg_projectid_de.

" SCREEN 0800 Data ~ Add To Team Screen

DATA: p_add_team_id TYPE zmg_teamid_de,
      p_add_user    TYPE zmg_username_de.

" SCREEN 0900 Data ~ Feedback Screen

DATA: p_type_of_request    TYPE zmg_fdbk_type_de,
      p_requestor_username TYPE zmg_username_de,
      lv_fb_exp            TYPE string,
      lv_fb_netw           TYPE string,
      lv_fb_team           TYPE string,
      lv_fb_lead           TYPE string,
      ls_current_fb        TYPE zmg_s_feedback,
      lt_txt_exp           TYPE TABLE OF zmg_fdbk_message_exp_de,
      lt_txt_netw          TYPE TABLE OF zmg_fdbk_message_netw_de,
      lt_txt_team          TYPE TABLE OF zmg_fdbk_message_team_de,
      lt_txt_lead          TYPE TABLE OF zmg_fdbk_message_leader_de,
      lv_read_only         TYPE abap_bool,
      lv_too_long          TYPE abap_bool VALUE abap_false,
      rb_exp_1             TYPE char1,
      rb_exp_2             TYPE char1,
      rb_exp_3             TYPE char1,
      rb_exp_4             TYPE char1,
      rb_exp_5             TYPE char1,
      rb_netw_1            TYPE char1,
      rb_netw_2            TYPE char1,
      rb_netw_3            TYPE char1,
      rb_netw_4            TYPE char1,
      rb_netw_5            TYPE char1,
      rb_team_1            TYPE char1,
      rb_team_2            TYPE char1,
      rb_team_3            TYPE char1,
      rb_team_4            TYPE char1,
      rb_team_5            TYPE char1,
      rb_lead_1            TYPE char1,
      rb_lead_2            TYPE char1,
      rb_lead_3            TYPE char1,
      rb_lead_4            TYPE char1,
      rb_lead_5            TYPE char1,
      lv_exp_grade         TYPE zmg_fdbk_grade_exp_de,
      lv_netw_grade        TYPE zmg_fdbk_grade_netw_de,
      lv_team_grade        TYPE zmg_fdbk_grade_team_de,
      lv_lead_grade        TYPE zmg_fdbk_grade_leader_de.

" SCREEN 1000 Data ~ Change password screen

DATA: p_r_password       TYPE zmg_password_de,
      p_new_password     TYPE zmg_password_de,
      p_current_password TYPE zmg_password_de.
