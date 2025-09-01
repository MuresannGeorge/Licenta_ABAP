class ZMG_CL_USER definition
  public
  create public .

public section.

  types:
    tt_user TYPE TABLE OF zmg_users .

  methods CONSTRUCTOR
    importing
      !IS_USER type ZMG_S_USER .
  methods GET_DEVELOPERS
    exporting
      !ET_DEVELOPERS type TT_USER .
  methods GET_MANAGERS
    exporting
      !ET_MANAGER type TT_USER .
  methods GET_MANAGER_OF_USER
    exporting
      !ES_MANAGER_OF_USER type ZMG_S_USER .
  methods GET_DEVELOPERS_OF_TEAM
    importing
      !IV_TEAM_ID type ZMG_TEAMID_DE
    exporting
      !ET_DEVELOPERS_OF_TEAM type TT_USER .
  methods BUILD_THE_TEAM
    exporting
      !ET_TEAM type TT_USER .
  methods CREATE_USER
    importing
      !IS_NEW_USER type ZMG_S_USER .
  methods CHANGE_PASSWORD
    importing
      !IS_USER type ZMG_S_USER
      !IV_NEW_PASSWORD type ZMG_PASSWORD_DE .
  methods GET_USERS
    exporting
      !ET_USERS type TT_USER .
  methods GET_CURRENT_USER
    exporting
      !ES_CURRENT_USER type ZMG_S_USER .
  methods ADD_USER_TO_TEAM
    importing
      !IV_USERNAME type ZMG_USERNAME_DE
      !IV_TEAM_ID type ZMG_TEAMID_DE .
protected section.
private section.

  data:
    mt_developers TYPE TABLE OF zmg_users .
  data:
    mt_managers TYPE TABLE OF zmg_users .
  data:
    mt_all_users TYPE TABLE OF zmg_users .
  data MS_CURRENT_USER type ZMG_S_USER .
ENDCLASS.



CLASS ZMG_CL_USER IMPLEMENTATION.


  METHOD add_user_to_team.
    DATA ls_user TYPE zmg_s_user.

    READ TABLE mt_all_users WITH KEY username = iv_username INTO ls_user.
    IF sy-subrc EQ 0.
      UPDATE zmg_users
      SET teamid = @iv_team_id
      WHERE username   = @ls_user-username.
      IF sy-subrc EQ 0.
        MESSAGE 'The user was addeed successfully' TYPE 'S'.
      ELSE.
        MESSAGE 'Something went wrong' TYPE 'S' DISPLAY LIKE 'W'.
      ENDIF.
    ELSE.
      MESSAGE 'The user dose not exist' TYPE 'S' DISPLAY LIKE 'W'.
    ENDIF.

  ENDMETHOD.


  METHOD build_the_team.

    DATA: ls_manager   TYPE zmg_s_user,
          lt_developer TYPE TABLE OF zmg_s_user,
          lt_team      TYPE TABLE OF zmg_s_user.

    IF ms_current_user-role = zmg_if_constans=>sc_user_role-developer.
      get_manager_of_user(
        IMPORTING
          es_manager_of_user = ls_manager    " User Structure
      ).

      APPEND ls_manager TO lt_team.
    ENDIF.
    get_developers_of_team(
      EXPORTING
        iv_team_id            = ms_current_user-teamid                 " Team ID Data Element
      IMPORTING
        et_developers_of_team = lt_developer
    ).

    LOOP AT lt_developer ASSIGNING FIELD-SYMBOL(<fs_developer>) WHERE username NE ms_current_user-username.
      APPEND <fs_developer> TO lt_team.
    ENDLOOP.

    et_team = lt_team.

  ENDMETHOD.


  METHOD change_password.

    READ TABLE mt_all_users WITH KEY userid = is_user-userid TRANSPORTING NO FIELDS.
    IF sy-subrc EQ 0.
      UPDATE zmg_users
      SET password = @iv_new_password,
          first_password = @abap_false
      WHERE userid   = @is_user-userid.
    ENDIF.

  ENDMETHOD.


  METHOD constructor.

    SELECT * FROM zmg_users
      INTO CORRESPONDING FIELDS OF TABLE mt_all_users.

    SELECT * FROM zmg_users
      INTO CORRESPONDING FIELDS OF TABLE mt_developers
      WHERE role = zmg_if_constans=>sc_user_role-developer.

    SELECT * FROM zmg_users
      INTO CORRESPONDING FIELDS OF TABLE mt_managers
      WHERE role = zmg_if_constans=>sc_user_role-manager.

    ms_current_user = is_user.

  ENDMETHOD.


  METHOD create_user.
    DATA: ls_new_user TYPE zmg_s_user.

    ls_new_user = is_new_user.

    CALL FUNCTION 'NUMBER_GET_NEXT'
      EXPORTING
        nr_range_nr = '01'
        object      = 'ZMG_USER'
      IMPORTING
        number      = ls_new_user-userid.
    ls_new_user-first_password = abap_true.

    INSERT zmg_users FROM ls_new_user.
        IF sy-subrc EQ 0.
      MESSAGE 'User created successfully' TYPE 'S'.
    ELSE.
      MESSAGE 'Something went wrong' TYPE 'S' DISPLAY LIKE 'W'.
    ENDIF.

  ENDMETHOD.


  METHOD get_current_user.

    es_current_user = ms_current_user.

  ENDMETHOD.


  method GET_DEVELOPERS.

   et_developers = mt_developers.

  endmethod.


  METHOD get_developers_of_team.
    DATA: lt_developers_of_team TYPE tt_user.

    LOOP AT mt_developers ASSIGNING FIELD-SYMBOL(<fs_developer>) WHERE teamid = iv_team_id.
      APPEND <fs_developer> TO lt_developers_of_team.
    ENDLOOP.
    et_developers_of_team = lt_developers_of_team.

  ENDMETHOD.


  method GET_MANAGERS.
    et_manager = mt_managers.
  endmethod.


  METHOD get_manager_of_user.
    DATA: ls_team TYPE zmg_s_team.

    SELECT SINGLE * FROM zmg_teams
      INTO ls_team
      WHERE teamid = ms_current_user-teamid.

    READ TABLE mt_managers WITH KEY userid = ls_team-managerid INTO es_manager_of_user.

  ENDMETHOD.


  METHOD get_users.

    et_users = mt_all_users.

  ENDMETHOD.
ENDCLASS.
