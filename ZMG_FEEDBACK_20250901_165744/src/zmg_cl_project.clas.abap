class ZMG_CL_PROJECT definition
  public
  final
  create public .

public section.

  methods CONSTRUCTOR .
  methods ADD_USER_TO_PROJECT
    importing
      !IO_USER type ref to ZMG_CL_USER
      !IS_USER_NAME type ZMG_USERNAME_DE
      !IV_PROJECT_ID type ZMG_PROJECTID_DE .
protected section.
private section.

  data:
    mt_all_projects TYPE TABLE OF zmg_s_project .
ENDCLASS.



CLASS ZMG_CL_PROJECT IMPLEMENTATION.


  METHOD add_user_to_project.
    DATA: lt_developer TYPE TABLE OF zmg_s_user,
          ls_prodev    TYPE zmg_s_projdev.

    io_user->get_developers(
      IMPORTING
        et_developers = lt_developer                 " USERS Table
    ).

    READ TABLE mt_all_projects ASSIGNING FIELD-SYMBOL(<fs_project>) WITH KEY project_id = iv_project_id.
    IF sy-subrc EQ 0..
      READ TABLE lt_developer ASSIGNING FIELD-SYMBOL(<fs_developer>) WITH KEY username = is_user_name.
      IF sy-subrc EQ 0.
        ls_prodev-dev_id = <fs_developer>-userid.
        ls_prodev-dev_name = <fs_developer>-username.
        ls_prodev-project_id = <fs_project>-project_id.
        ls_prodev-project_name = <fs_project>-project_name.

        INSERT zmg_projsdev FROM ls_prodev.
        IF sy-subrc EQ 0.
          MESSAGE 'User added successfully to the project' TYPE 'S'.
        ELSE.
          MESSAGE 'Something went wrong' TYPE 'S' DISPLAY LIKE 'W'.
        ENDIF.
      ELSE.
        MESSAGE 'Developer dose not exist' TYPE 'S' DISPLAY LIKE 'W'.
      ENDIF.
    ELSE.
      MESSAGE 'Project dose not exist' TYPE 'S' DISPLAY LIKE 'W'.
    ENDIF.

  ENDMETHOD.


  method CONSTRUCTOR.

    SELECT * FROM zmg_projects
      INTO CORRESPONDING FIELDS OF TABLE mt_all_projects.

  endmethod.
ENDCLASS.
