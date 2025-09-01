class ZMG_CL_TEAM definition
  public
  final
  create public .

public section.

  methods CONSTRUCTOR
    importing
      !IS_USER type ZMG_S_USER .
  methods GET_TEAM_NAME
    exporting
      !EV_TEAM_NAME type ZMG_TEAMNAME_DE .
  methods CREATE_TEAM
    importing
      !IV_TEAM_NAME type ZMG_TEAMNAME_DE
      !IV_TEAM_MANAGER type ZMG_MANAGERID_DE .
  methods CHECK_IF_TEAM_EXISTS
    importing
      !IV_TEAM_NAME type ZMG_TEAMNAME_DE optional
      !IV_TEAM_ID type ZMG_TEAMID_DE optional
    exporting
      !EV_EXISTS type ABAP_BOOL .
protected section.
private section.

  data:
    mt_team TYPE TABLE OF zmg_teams .
  data MS_CURRENT_TEAM type ZMG_S_TEAM .
ENDCLASS.



CLASS ZMG_CL_TEAM IMPLEMENTATION.


  METHOD check_if_team_exists.
    DATA: lv_team_name TYPE zmg_teamname_de.

    IF iv_team_name IS NOT INITIAL.
      READ TABLE mt_team WITH KEY teamname = iv_team_name TRANSPORTING NO FIELDS.
      IF sy-subrc EQ 0.
        ev_exists = abap_true.
      ELSE.
        ev_exists = abap_false.
      ENDIF.
      RETURN.
    ELSEIF iv_team_id IS NOT INITIAL.
      READ TABLE mt_team WITH KEY teamid = iv_team_id TRANSPORTING NO FIELDS.
      IF sy-subrc EQ 0.
        ev_exists = abap_true.
      ELSE.
        ev_exists = abap_false.
      ENDIF.
      RETURN.
    ENDIF.
  ENDMETHOD.


  method CONSTRUCTOR.

    SELECT * from zmg_teams
      INTO CORRESPONDING FIELDS OF TABLE mt_team.

    READ TABLE mt_team with key teamid = is_user-teamid INTO ms_current_team.

  endmethod.


  METHOD create_team.

    DATA: ls_new_team TYPE zmg_s_team.

    CALL FUNCTION 'NUMBER_GET_NEXT'
      EXPORTING
        nr_range_nr = '01'
        object      = 'ZMG_TEAM'
      IMPORTING
        number      = ls_new_team-teamid.
    ls_new_team-managerid = iv_team_manager.
    ls_new_team-teamname = iv_team_name.

    INSERT zmg_teams FROM ls_new_team.
    IF sy-subrc EQ 0.
      MESSAGE 'Team created successfully' TYPE 'S'.
    ELSE.
      MESSAGE 'Something went wrong' TYPE 'S' DISPLAY LIKE 'W'.
    ENDIF.

  ENDMETHOD.


  METHOD get_team_name.

    ev_team_name = ms_current_team-teamname.

  ENDMETHOD.
ENDCLASS.
