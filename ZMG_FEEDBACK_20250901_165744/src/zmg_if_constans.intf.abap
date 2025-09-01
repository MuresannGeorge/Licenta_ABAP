INTERFACE zmg_if_constans
  PUBLIC .


  CONSTANTS:
    BEGIN OF sc_user_role,
      manager   TYPE char20 VALUE 'MANAGER',
      developer TYPE char20 VALUE 'DEVELOPER',
      project_manager TYPE  char20 VALUE 'PROJECT MANAGER',
    END OF sc_user_role .
  CONSTANTS:
    BEGIN OF sc_feedback_type,
      my_year_reviw      TYPE zmg_fdbk_type_de VALUE 'MYR',
      final_year_review  TYPE zmg_fdbk_type_de VALUE 'FYR',
      project_evaluation TYPE zmg_fdbk_type_de VALUE 'PME',
    END OF sc_feedback_type .
  CONSTANTS:
    BEGIN OF sc_feedback_status,
      pending   TYPE zmg_fdbk_status_de VALUE 'Pending',
      opened    TYPE zmg_fdbk_status_de VALUE 'Opened',
      completed TYPE zmg_fdbk_status_de VALUE 'Completed',
    END OF sc_feedback_status.

ENDINTERFACE.
