class ZMG_CL_FEEDBACK definition
  public
  final
  create public .

public section.

  types:
    tt_feedback_message TYPE TABLE OF zmg_fdbk_message_de .
  types:
    TT_MY_FEEDBACK TYPE TABLE OF zmg_s_my_feedback .

  methods CONSTRUCTOR .
  methods SEND_FEEDBACK
    importing
      !IS_USER type ZMG_S_USER
      !IV_FEEDBACK_TYPE type ZMG_FDBK_TYPE_DE
      !IV_ANONYMITY type ZMG_FDBK_ANON_DE .
  methods REQUEST_PEG_FEEDBACK
    importing
      !IS_USER type ZMG_S_USER
      !IS_PROJECT type ZMG_S_PROJECT
      !IV_ANONYMITY type ZMG_FDBK_ANON_DE
      !IV_REQUEST_TYPE type ZMG_FDBK_TYPE_DE
      !IO_USER type ref to ZMG_CL_USER .
  methods GET_MY_REQUEST
    importing
      !IS_USER type ZMG_S_USER
    exporting
      !ET_MY_FEEDBACK type TT_MY_FEEDBACK .
  methods REQUEST_MANAGER_FEEDBACK
    importing
      !IO_USER type ref to ZMG_CL_USER
      !IV_FEEDBACK_TYPE type ZMG_FDBK_TYPE_DE .
  methods SET_CURRENT_FEEDBACK
    importing
      !IV_FEEDBACK_ID type ZMG_FDBK_ID_DE .
  methods GET_CURRENT_FEEDBACK
    exporting
      !ES_CURRENT_FEEDBACK type ZMG_S_FEEDBACK .
  methods CALL_CONTAINER
    importing
      !IO_CONTAINER type ref to CL_GUI_CUSTOM_CONTAINER
      !IO_TEXT_EDIT type ref to CL_GUI_TEXTEDIT
      !IV_TEXT type ZMG_FDBK_MESSAGE_DE
      !IV_READ_ONLY type ABAP_BOOL .
  methods UPDATE_FEEDBACK
    importing
      !IT_TEXT_EXP type TT_FEEDBACK_MESSAGE
      !IT_TEXT_NETW type TT_FEEDBACK_MESSAGE
      !IT_TEXT_TEAM type TT_FEEDBACK_MESSAGE
      !IT_TEXT_LEAD type TT_FEEDBACK_MESSAGE
      !IV_EXP_GRADE type ZMG_FDBK_GRADE_EXP_DE
      !IV_NETW_GRADE type ZMG_FDBK_GRADE_NETW_DE
      !IV_TEAM_GRADE type ZMG_FDBK_GRADE_TEAM_DE
      !IV_LEAD_GRADE type ZMG_FDBK_GRADE_LEADER_DE
      !IV_STATUS type ZMG_FDBK_STATUS_DE .
protected section.
private section.

  data:
    mt_feedback_PEG TYPE TABLE OF zmg_s_feedback .
  data:
    mt_feedback_M TYPE TABLE OF zmg_s_feedback .
  data MS_FEEDBACK_PEG type ZMG_S_FEEDBACK .
  data MS_FEEDBACK_M type ZMG_S_FEEDBACK .
  data:
    mt_all_feedbacks TYPE TABLE OF zmg_s_feedback .
  data MS_CURRENT_FEEDBACK type ZMG_S_FEEDBACK .

  methods SET_M_FEEDBACK .
  methods SET_PEG_FEEDBACK .
  methods SET_ALL_FEEDBACKS .
ENDCLASS.



CLASS ZMG_CL_FEEDBACK IMPLEMENTATION.


  METHOD call_container.

    DATA: lt_text        TYPE TABLE OF zmg_fdbk_message_de,
          lv_read_status TYPE i.

    APPEND iv_text TO lt_text.

    IF iv_read_only EQ abap_true.
      lv_read_status = 1.
    ELSE.
      lv_read_status = 0.
    ENDIF.

    io_text_edit->set_toolbar_mode( ).
    io_text_edit->set_statusbar_mode( ).
    io_text_edit->set_readonly_mode(
      EXPORTING
        readonly_mode          = lv_read_status             " read-only mode; eq 0: OFF ; ne 0: ON
    ).
    io_text_edit->set_wordwrap_behavior(
      EXPORTING
        wordwrap_mode              = 1               " 0: OFF; 1: wrap a window border; 2: wrap at fixed position
    ).
    io_text_edit->set_text_as_stream(
      EXPORTING
        text            = lt_text               " text as stream with carrige retruns and linefeeds
    ).


  ENDMETHOD.


  METHOD constructor.
    me->set_m_feedback( ).
    me->set_peg_feedback( ).
    me->set_all_feedbacks( ).
  ENDMETHOD.


  METHOD get_current_feedback.

    es_current_feedback = ms_current_feedback.

  ENDMETHOD.


  METHOD get_my_request.

    DATA lt_feedback TYPE TABLE OF zmg_s_feedback.
    FIELD-SYMBOLS <fs_feedback> TYPE zmg_s_feedback.

    IF is_user-role = zmg_if_constans=>sc_user_role-developer.

      LOOP AT mt_feedback_m ASSIGNING <fs_feedback>
         WHERE requestor_id = is_user-userid.
        IF <fs_feedback>-anonymity = abap_true.
          <fs_feedback>-requestor_id = ''.
          <fs_feedback>-requestor_name = ''.
        ENDIF.
        APPEND <fs_feedback> TO lt_feedback.
      ENDLOOP.

      LOOP AT mt_feedback_peg ASSIGNING <fs_feedback>
        WHERE requestor_id = is_user-userid.
        IF <fs_feedback>-anonymity = abap_true.
          <fs_feedback>-requestor_id = ''.
          <fs_feedback>-requestor_name = ''.
        ENDIF.
        APPEND <fs_feedback> TO lt_feedback.
      ENDLOOP.

      MOVE-CORRESPONDING lt_feedback TO et_my_feedback.

    ELSEIF is_user-role = zmg_if_constans=>sc_user_role-manager.

      LOOP AT mt_feedback_m ASSIGNING <fs_feedback>
        WHERE replier_id = is_user-userid.
        IF <fs_feedback>-anonymity = abap_true.
          <fs_feedback>-requestor_id = ''.
          <fs_feedback>-requestor_name = ''.
        ENDIF.
        APPEND <fs_feedback> TO lt_feedback.
      ENDLOOP.

      LOOP AT mt_feedback_peg ASSIGNING <fs_feedback>
        WHERE replier_id = is_user-userid.
        IF <fs_feedback>-anonymity = abap_true.
          <fs_feedback>-requestor_id = ''.
          <fs_feedback>-requestor_name = ''.
        ENDIF.
        APPEND <fs_feedback> TO lt_feedback.
      ENDLOOP.

      MOVE-CORRESPONDING lt_feedback TO et_my_feedback.

    ENDIF.


  ENDMETHOD.


  METHOD request_manager_feedback.

    DATA: ls_feedback    TYPE zmg_s_feedback,
          ls_manager     TYPE zmg_s_user,
          ls_developer   TYPE zmg_s_user,
          lv_feedback_id TYPE i.

    io_user->get_manager_of_user(
      IMPORTING
        es_manager_of_user = ls_manager                 " User Structure
    ).
    io_user->get_current_user(
      IMPORTING
        es_current_user = ls_developer                " User Structure
    ).
    CALL FUNCTION 'NUMBER_GET_NEXT'
      EXPORTING
        nr_range_nr = '01'
        object      = 'ZMG_FEEDBA'
      IMPORTING
        number      = ls_feedback-feedback_id.
    ls_feedback-replier_id = ls_manager-userid.
    ls_feedback-replier_name = ls_manager-username.
    ls_feedback-requestor_id = ls_developer-userid.
    ls_feedback-requestor_name = ls_developer-username.
    ls_feedback-status = zmg_if_constans=>sc_feedback_status-pending.
    ls_feedback-type = iv_feedback_type.
    ls_feedback-fdate = sy-datum.

    INSERT zmg_feedback FROM ls_feedback.

  ENDMETHOD.


  METHOD request_peg_feedback.
    DATA: ls_request TYPE zmg_s_feedback,
          lt_manager TYPE TABLE OF zmg_s_user.

    CALL FUNCTION 'NUMBER_GET_NEXT'
      EXPORTING
        nr_range_nr = '01'
        object      = 'ZMG_FEEDBA'
      IMPORTING
        number      = ls_request-feedback_id.

    ls_request-requestor_id = is_user-userid.
    ls_request-requestor_name = is_user-username.
    ls_request-replier_id = is_project-managerid.

    "Get managers to find the manager's name
    io_user->get_managers(
      IMPORTING
        et_manager = lt_manager
    ).

    READ TABLE lt_manager WITH KEY userid = is_project-managerid ASSIGNING FIELD-SYMBOL(<fs_project_manager>).

    ls_request-replier_name = <fs_project_manager>-username.
    ls_request-project_id = is_project-project_id.
    ls_request-project_name = is_project-project_name.
    ls_request-status = zmg_if_constans=>sc_feedback_status-pending.
    ls_request-fdate = sy-datum.
    ls_request-anonymity = iv_anonymity.
    ls_request-type = iv_request_type.

    INSERT INTO zmg_feedback VALUES ls_request.

  ENDMETHOD.


  method SEND_FEEDBACK.

  endmethod.


  METHOD set_all_feedbacks.

    SELECT *
      FROM zmg_feedback
      INTO CORRESPONDING FIELDS OF TABLE mt_all_feedbacks.

  ENDMETHOD.


  METHOD set_current_feedback.

    READ TABLE mt_all_feedbacks WITH KEY feedback_id = iv_feedback_id INTO ms_current_feedback.

  ENDMETHOD.


  METHOD SET_M_FEEDBACK.

    SELECT * FROM zmg_feedback
      INTO CORRESPONDING FIELDS OF TABLE mt_feedback_m
      WHERE type = zmg_if_constans=>sc_feedback_type-my_year_reviw or type = zmg_if_constans=>sc_feedback_type-final_year_review .

  ENDMETHOD.


  METHOD SET_PEG_FEEDBACK.

    SELECT * FROM zmg_feedback
      INTO CORRESPONDING FIELDS OF TABLE mt_feedback_peg
      WHERE type = zmg_if_constans=>sc_feedback_type-project_evaluation.

  ENDMETHOD.


  METHOD update_feedback.
    DATA: lv_text_exp  TYPE zmg_fdbk_message_de,
          lv_text_netw TYPE zmg_fdbk_message_de,
          lv_text_team TYPE zmg_fdbk_message_de,
          lv_text_lead TYPE zmg_fdbk_message_de.

    READ TABLE it_text_exp INDEX 1 INTO lv_text_exp.

    IF sy-subrc NE 0.
      lv_text_exp = ms_current_feedback-message_exp.
    ELSE.
      ms_current_feedback-message_exp = lv_text_exp.
    ENDIF.

    READ TABLE it_text_netw INDEX 1 INTO lv_text_netw.

    IF sy-subrc NE 0.
      lv_text_netw = ms_current_feedback-message_netw.
    ELSE.
      ms_current_feedback-message_netw = lv_text_netw.
    ENDIF.

    READ TABLE it_text_team INDEX 1 INTO lv_text_team.

    IF sy-subrc NE 0.
      lv_text_team = ms_current_feedback-message_team.
    ELSE.
      ms_current_feedback-message_team = lv_text_team.
    ENDIF.

    READ TABLE it_text_lead INDEX 1 INTO lv_text_lead.

    IF sy-subrc NE 0.
      lv_text_lead = ms_current_feedback-message_leader.
    ELSE.
      ms_current_feedback-message_leader = lv_text_lead.
    ENDIF.

    ms_current_feedback-grade_exp = iv_exp_grade.
    ms_current_feedback-grade_leader = iv_lead_grade.
    ms_current_feedback-grade_netw = iv_netw_grade.
    ms_current_feedback-grade_team = iv_team_grade.

    UPDATE zmg_feedback
    SET message_exp = @lv_text_exp,
        message_leader = @lv_text_lead,
        message_netw = @lv_text_netw,
        message_team = @lv_text_team,
        grade_exp = @iv_exp_grade,
        grade_leader = @iv_lead_grade,
        grade_netw = @iv_netw_grade,
        grade_team = @iv_team_grade,
        status = @iv_status
    WHERE feedback_id = @ms_current_feedback-feedback_id.

  ENDMETHOD.
ENDCLASS.
