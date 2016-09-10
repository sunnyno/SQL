CREATE OR REPLACE PROCEDURE del_all_objects IS
  owe              VARCHAR2(30) DEFAULT '';
  del_priv         VARCHAR2(2);
  check_rest       VARCHAR2(30) DEFAULT '';
  CURSOR constr_cur IS (
    SELECT
      TABLE_NAME,
      CONSTRAINT_NAME
    FROM (
      SELECT
        TABLE_NAME,
        CONSTRAINT_NAME

      FROM USER_CONSTRAINTS
      WHERE CONSTRAINT_TYPE IN ('R', 'U', 'P')
      ORDER BY decode(CONSTRAINT_TYPE, 'R', 1, 'U', 2, 'P', 3, 4)));

  v_procedure_name VARCHAR2(32) := $$PLSQL_UNIT;

  CURSOR obj_cur IS (
    SELECT
      object_type,
      object_name
    FROM (
      SELECT
        OBJECT_TYPE,
        OBJECT_NAME
      FROM user_objects
      WHERE OBJECT_NAME != v_procedure_name
      ORDER BY
        decode(OBJECT_TYPE, 'SYNONYM', 0, 'VIEW', 1, 'INDEX', 2, 'TRIGGER', 3, 'TABLE', 4, 'SEQUENCE', 5, 'PROCEDURE',
               6,
               'FUNCTION', 7, 'PACKAGE', 8, 'PACKAGE BODY', 9, 10)
    )
  );

    go_out EXCEPTION;

  BEGIN
    --check whether you can see the schema
    BEGIN
      SELECT DISTINCT owner
      INTO owe
      FROM ALL_OBJECTS
      WHERE owner = user;

      EXCEPTION WHEN NO_DATA_FOUND THEN
      dbms_output.put_line('Schema does not exist or you have no grants on it');
      RAISE go_out;
    END;

    --delete constraints
    FOR x IN constr_cur LOOP
      DBMS_OUTPUT.PUT_LINE(
          'ALTER TABLE ' || user || '.' || x.TABLE_NAME || ' DROP CONSTRAINT ' || x.CONSTRAINT_NAME);
      EXECUTE IMMEDIATE 'ALTER TABLE ' || x.TABLE_NAME || ' DROP CONSTRAINT ' || x.CONSTRAINT_NAME;
    END LOOP;

    --drop objects
    FOR y IN obj_cur LOOP
      DBMS_OUTPUT.PUT_LINE('DROP ' || y.object_type || ' ' || y.object_name);
      EXECUTE IMMEDIATE 'DROP ' || y.object_type || ' ' || y.object_name;
    END LOOP;
    BEGIN
      SELECT OBJECT_NAME
      INTO check_rest
      FROM USER_OBJECTS;
      IF check_rest = v_procedure_name
      THEN
        DBMS_OUTPUT.PUT_LINE('completed');
      END IF;
      EXCEPTION WHEN NO_DATA_FOUND THEN DBMS_OUTPUT.PUT_LINE('completed');
    END;
    COMMIT;

    EXCEPTION
    WHEN go_out THEN DBMS_OUTPUT.PUT_LINE('exiting...');

  END;
