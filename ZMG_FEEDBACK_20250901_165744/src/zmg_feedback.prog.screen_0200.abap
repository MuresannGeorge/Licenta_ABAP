PROCESS BEFORE OUTPUT.
  MODULE status_0200.
  CALL SUBSCREEN sub_manager INCLUDING sy-repid lv_screen.
*
PROCESS AFTER INPUT.
  CALL SUBSCREEN sub_manager.
  MODULE user_command_0200.
