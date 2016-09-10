-- Написать хранимую процедуру, которая создает копию hr.employees и принимает параметры
-- список столбцов для игнорирования при созании копии, разделенный запятыми
-- Id_min ,id_max (может быть NULL, тогда не ограничено) - диапазон значений employee_id
-- Строка дополнительного кастомного условия.
-- При возможности создать индексы и ограничения по тем же колонкам.


--a procedure to create the copy of EMPLOYEES table with some conditions
CREATE OR REPLACE PROCEDURE create_employees(columns_to_ignore IN VARCHAR2 DEFAULT NULL,
                                             id_min            IN EMPLOYEES.EMPLOYEE_ID%TYPE DEFAULT NULL,
                                             id_max            IN EMPLOYEES.EMPLOYEE_ID%TYPE DEFAULT NULL,
                                             cus_condition     IN VARCHAR2 DEFAULT NULL) IS
  col_names       VARCHAR2(32767);
  id_min_in_table EMPLOYEES.EMPLOYEE_ID%TYPE;
  id_max_in_table EMPLOYEES.EMPLOYEE_ID%TYPE;

  BEGIN
    --extract columns to add into a new table
    SELECT listagg(column_name, ',')
           WITHIN GROUP (
             ORDER BY ROWNUM) col
    INTO col_names
    FROM ALL_TAB_COLUMNS
    WHERE owner = 'HR' AND table_name = 'EMPLOYEES' AND column_name NOT IN (
      SELECT regexp_substr(columns_to_ignore, '[^, ]+', 1, level) --parse the input string of columns to ignore
      FROM dual
      CONNECT BY regexp_substr(columns_to_ignore, '[^, ]+', 1, level) IS NOT NULL);
    SELECT min(EMPLOYEE_ID)
    INTO id_min_in_table
    FROM EMPLOYEES;
    SELECT max(EMPLOYEE_ID)
    INTO id_max_in_table
    FROM EMPLOYEES;

    EXECUTE IMMEDIATE 'CREATE TABLE dynamic_employees AS SELECT ' || nvl(col_names, 'EMPLOYEE_ID,
                 FIRST_NAME,
                 LAST_NAME,
                 EMAIL,
                 PHONE_NUMBER,
                 HIRE_DATE,
                 JOB_ID,
                 SALARY,
                 COMMISSION_PCT,
                 MANAGER_ID,
                 DEPARTMENT_ID') || '
                      FROM EMPLOYEES WHERE EMPLOYEE_ID BETWEEN ' || nvl(id_min, id_min_in_table) ||
                      ' AND ' || nvl(id_max, id_max_in_table) || ' AND ' || nvl(cus_condition, '1=1');
    add_cons_dyn_emp(nvl(col_names, 'EMPLOYEE_ID,
                 FIRST_NAME,
                 LAST_NAME,
                 EMAIL,
                 PHONE_NUMBER,
                 HIRE_DATE,
                 JOB_ID,
                 SALARY,
                 COMMISSION_PCT,
                 MANAGER_ID,
                 DEPARTMENT_ID'));
    add_ind_dyn_emp(nvl(col_names, ' EMPLOYEE_ID,
                 FIRST_NAME,
                 LAST_NAME,
                 EMAIL,
                 PHONE_NUMBER,
                 HIRE_DATE,
                 JOB_ID,
                 SALARY,
                 COMMISSION_PCT,
                 MANAGER_ID,
                 DEPARTMENT_ID'));
    COMMIT;
    EXCEPTION WHEN OTHERS THEN DBMS_OUTPUT.put_line('Error creating table');

  END;

--a procedure to add constraints to DYNAMIC_EMPLOYEES table which were in original EMPLOYEES table
CREATE OR REPLACE PROCEDURE add_cons_dyn_emp(col_names IN VARCHAR2 DEFAULT 'EMPLOYEE_ID,
                 FIRST_NAME,
                 LAST_NAME,
                 EMAIL,
                 PHONE_NUMBER,
                 HIRE_DATE,
                 JOB_ID,
                 SALARY,
                 COMMISSION_PCT,
                 MANAGER_ID,
                 DEPARTMENT_ID') IS
  CURSOR cons_cursor IS SELECT ddl
                        FROM (SELECT
                                --select foreign key constraints
                                DBMS_METADATA.get_ddl('REF_CONSTRAINT', constraint_name, owner) ddl,
                                constraint_name
                              FROM all_constraints
                              WHERE owner = 'HR'
                                    AND table_name = 'EMPLOYEES'
                                    AND constraint_type = 'R'
                              UNION ALL
                              --select all the rest of constraints
                              SELECT
                                DBMS_METADATA.get_ddl('CONSTRAINT', constraint_name, owner) ddl,
                                constraint_name
                              FROM all_constraints
                              WHERE owner = 'HR'
                                    AND table_name = 'EMPLOYEES'
                                    AND constraint_type IN ('U', 'P', 'C'))
                        WHERE constraint_name IN
                              --not null constraints should be excepted as they are added automatically
                              --self foreign keys should be excepted too as there can be no employee_id value due to id-filtering when creating table
                              (SELECT constraint_name
                               FROM all_cons_columns
                               WHERE owner = 'HR' AND table_name = 'EMPLOYEES' AND
                                     --except columns which should be ignored
                                     column_name NOT IN
                                     (col_names))
                              AND constraint_name NOT IN (SELECT a.constraint_name
                                                          FROM all_cons_columns a
                                                            --join is to get 'nullable' field to except not null constraints
                                                            JOIN ALL_TAB_COLUMNS c
                                                              ON a.owner = c.owner
                                                                 AND
                                                                 a.column_name =
                                                                 c.column_name
                                                            JOIN ALL_CONSTRAINTS b ON b.owner = a.owner AND
                                                                                      b.constraint_name =
                                                                                      a.constraint_name
                                                            --join is to get self foreign keys
                                                            LEFT JOIN
                                                            all_constraints c_pk ON
                                                                                   b.r_owner
                                                                                   =
                                                                                   c_pk.owner
                                                                                   AND
                                                                                   b.r_constraint_name
                                                                                   =
                                                                                   c_pk.constraint_name
                                                          WHERE a.table_name = 'EMPLOYEES' AND nullable = 'N' AND
                                                                b.constraint_type = 'C' OR
                                                                b.constraint_type = 'R' AND a.table_name =
                                                                                            c_pk.table_name AND
                                                                a.table_name = 'EMPLOYEES');

  cons_str VARCHAR2(500);
  BEGIN
    OPEN cons_cursor;
    LOOP
      FETCH cons_cursor INTO cons_str;
      EXIT WHEN cons_cursor%NOTFOUND;
      --correct the extracted ddl to match the DYNAMIC_EMPLOYEES table
      SELECT regexp_replace(cons_str, 'EMPLOYEES', 'DYNAMIC_EMPLOYEES')
      INTO cons_str
      FROM DUAL;
      SELECT regexp_replace(cons_str, '"EMP_', '"DYN_EMP_')
      INTO cons_str
      FROM DUAL;
      DBMS_OUTPUT.put_line(cons_str);
      EXECUTE IMMEDIATE cons_str;
    END LOOP;
    EXCEPTION WHEN OTHERS THEN DBMS_OUTPUT.put_line('Error adding constraint');
  END;


--a procedure to add indexes
CREATE OR REPLACE PROCEDURE add_ind_dyn_emp(col_names IN VARCHAR2 DEFAULT 'EMPLOYEE_ID,
                 FIRST_NAME,
                 LAST_NAME,
                 EMAIL,
                 PHONE_NUMBER,
                 HIRE_DATE,
                 JOB_ID,
                 SALARY,
                 COMMISSION_PCT,
                 MANAGER_ID,
                 DEPARTMENT_ID') IS
  --a record contains index name and indexed column name
  TYPE ind_and_col IS RECORD
  (ind VARCHAR2(30),
    col VARCHAR2(20));
  rec_col_ind ind_and_col;
  --cursor goes through the record
  CURSOR ind_cursor IS
    SELECT
      s1.i ind,
      c
    INTO rec_col_ind
    FROM
      --get indexes which are created automatically during creating constraints and except indexes on ignored colunms
      (SELECT
         regexp_replace(index_name, '^EMP_', 'DYN_EMP_') i,
         column_name                                     c
       FROM ALL_IND_COLUMNS
       WHERE table_owner = 'HR' AND table_name = 'EMPLOYEES') s1 FULL JOIN
      (SELECT index_name i
       FROM ALL_IND_COLUMNS
       WHERE table_owner = 'HR' AND table_name = 'DYNAMIC_EMPLOYEES') s2
        ON s1.i = s2.i
    WHERE s1.i IS NULL OR s2.i IS NULL
                          AND c NOT IN (col_names);

  ind_str     VARCHAR2(500);
  col_str     VARCHAR2(300);
  BEGIN
    OPEN ind_cursor;
    LOOP
      FETCH ind_cursor INTO ind_str, col_str;
      EXIT WHEN ind_cursor%NOTFOUND;
      DBMS_OUTPUT.put_line(ind_str || ' ,' || col_str);
      --the string to execute is taken from DBMS_METADATA package
      EXECUTE IMMEDIATE 'CREATE INDEX "HR"."' || ind_str || '" ON "HR"."DYNAMIC_EMPLOYEES" ("' || col_str || '")
          PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS
          STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
          PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
          TABLESPACE "USERS" ';
    END LOOP;
    EXCEPTION WHEN OTHERS THEN DBMS_OUTPUT.put_line('Error adding index');
  END;