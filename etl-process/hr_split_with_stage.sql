CREATE OR REPLACE PROCEDURE split_hr_2(from_id NUMBER DEFAULT 0) IS
  --var to check whether curr_id temp table exists
  test_curr_id VARCHAR2(20);
  --var to check whether emp2 table exists
  emp2_test    VARCHAR2(30);

  BEGIN
    --check emp2 existence
    BEGIN
      SELECT object_name
      INTO emp2_test
      FROM USER_OBJECTS
      WHERE object_type = 'TABLE' AND object_name = 'EMP2';

      EXCEPTION WHEN NO_DATA_FOUND THEN
      write_log(sysdate, 'ERROR', 'Table EMP2 does not exist');
    END;

    BEGIN
      SELECT object_name
      INTO test_curr_id
      FROM USER_OBJECTS
      WHERE object_type = 'TABLE' AND object_name = 'CURR_ID';
      EXCEPTION WHEN NO_DATA_FOUND THEN
      EXECUTE IMMEDIATE 'CREATE GLOBAL TEMPORARY TABLE curr_id(
                           id NUMBER(6)
                          )ON COMMIT DELETE ROWS';
    END;


    WRITE_LOG(sysdate, 'INFO', 'Starting loading data');

    BEGIN
       EXECUTE IMMEDIATE 'INSERT INTO curr_id SELECT EMPLOYEE_ID
                                             FROM (
                                                    SELECT EMPLOYEE_ID,
                                                      row_number() OVER (
                                                                  ORDER BY EMPLOYEE_ID) rn
                                                    FROM hr.employees
                                                    WHERE mod(employee_id, 2) = 1 AND employee_id > nvl((
                                                                                SELECT end_bm
                                                                                FROM BM
                                                                                WHERE
                                                                                  id = (SELECT max(id)
                                                                                        FROM BM
                                                                                        WHERE mod(end_bm, 2) = 1)),
                                                                              0)
                                                    AND employee_id >=' || from_id
                                        || ' )
                                             WHERE rn<=2';

      EXECUTE IMMEDIATE 'INSERT INTO BM SELECT
                       1,
                       ''Y'',
                       (SELECT min(ID)
                        FROM curr_id
                       ),
                       (SELECT max(id)
                        FROM curr_id)
                     FROM dual';

      EXECUTE IMMEDIATE 'MERGE INTO emp1
      USING (SELECT
               EMPLOYEE_ID,
               FIRST_NAME,
               LAST_NAME,
               EMAIL,
               PHONE_NUMBER,
               HIRE_DATE,
               JOB_ID,
               SALARY,
               COMMISSION_PCT,
               MANAGER_ID,
               DEPARTMENT_ID
             FROM hr.employees
               JOIN curr_id ON hr.employees.employee_id = curr_id.id) hr_e
      ON (hr_e.EMPLOYEE_ID = emp1.EMPLOYEE_ID)
      WHEN MATCHED THEN UPDATE SET emp1.FIRST_NAME = hr_e.first_name,
        emp1.LAST_NAME = hr_e.last_name,
        emp1.EMAIL = hr_e.email,
        emp1.PHONE_NUMBER = hr_e.phone_number,
        emp1.HIRE_DATE = hr_e.hire_date,
        emp1.JOB_ID = hr_e.job_id,
        emp1.SALARY = hr_e.salary,
        emp1.COMMISSION_PCT = hr_e.commission_pct,
        emp1.MANAGER_ID = hr_e.manager_id,
        emp1.DEPARTMENT_ID = hr_e.department_id
      WHEN NOT MATCHED THEN INSERT VALUES (hr_e.EMPLOYEE_ID,
        hr_e.FIRST_NAME,
        hr_e.LAST_NAME,
        hr_e.EMAIL,
        hr_e.PHONE_NUMBER,
        hr_e.HIRE_DATE,
        hr_e.JOB_ID,
        hr_e.SALARY,
        hr_e.COMMISSION_PCT,
        hr_e.MANAGER_ID,
        hr_e.DEPARTMENT_ID)';

      WRITE_LOG(sysdate, 'INFO', SQL%ROWCOUNT || ' rows affected into emp1');

      UPDATE BM
      SET ST = 'N'
      WHERE ID = (SELECT max(id)
                  FROM BM);
      COMMIT;
    END;


    BEGIN
      EXECUTE IMMEDIATE 'INSERT INTO curr_id SELECT EMPLOYEE_ID
                                             FROM (
                                                    SELECT EMPLOYEE_ID,
                                                      row_number() OVER (
                                                                  ORDER BY EMPLOYEE_ID) rn
                                                    FROM hr.employees
                                                    WHERE mod(employee_id, 2) = 0 AND employee_id > nvl((
                                                                                SELECT end_bm
                                                                                FROM BM
                                                                                WHERE
                                                                                  id = (SELECT max(id)
                                                                                        FROM BM
                                                                                        WHERE mod(end_bm, 2) = 0)),
                                                                              0)
                                                    AND employee_id >=' || from_id
                                        || ' )
                                             WHERE rn<=2';

      EXECUTE IMMEDIATE 'INSERT INTO TMP_EMP SELECT
                            EMPLOYEE_ID,
                            FIRST_NAME,
                            LAST_NAME,
                            EMAIL,
                            PHONE_NUMBER,
                            HIRE_DATE,
                            JOB_ID,
                            SALARY,
                            COMMISSION_PCT,
                            MANAGER_ID,
                            DEPARTMENT_ID
                          FROM hr.employees
                            JOIN curr_id ON hr.employees.employee_id = curr_id.id';
      WRITE_LOG(sysdate, 'INFO', SQL%ROWCOUNT || ' rows affected into tmp_emp');
      IF emp2_test IS NULL
      THEN
        WRITE_LOG(sysdate, 'ERROR', 'Emp2 does not exist.Can`t insert');
      ELSE
        EXECUTE IMMEDIATE '  INSERT INTO BM SELECT
                         1,
                         ''Y'',
                         (SELECT min(id)
                          FROM curr_id),
                         (SELECT max(id)
                          FROM curr_id
                         )
                       FROM dual';

        EXECUTE IMMEDIATE ' MERGE INTO emp2
        USING (SELECT
                 EMPLOYEE_ID,
                 FIRST_NAME,
                 LAST_NAME,
                 EMAIL,
                 PHONE_NUMBER,
                 HIRE_DATE,
                 JOB_ID,
                 SALARY,
                 COMMISSION_PCT,
                 MANAGER_ID,
                 DEPARTMENT_ID
               FROM TMP_EMP) hr_e
        ON (hr_e.EMPLOYEE_ID = emp2.EMPLOYEE_ID)
        WHEN MATCHED THEN UPDATE SET emp2.FIRST_NAME = hr_e.first_name,
          emp2.LAST_NAME = hr_e.last_name,
          emp2.EMAIL = hr_e.email,
          emp2.PHONE_NUMBER = hr_e.phone_number,
          emp2.HIRE_DATE = hr_e.hire_date,
          emp2.JOB_ID = hr_e.job_id,
          emp2.SALARY = hr_e.salary,
          emp2.COMMISSION_PCT = hr_e.commission_pct,
          emp2.MANAGER_ID = hr_e.manager_id,
          emp2.DEPARTMENT_ID = hr_e.department_id
        WHEN NOT MATCHED THEN INSERT VALUES (hr_e.EMPLOYEE_ID,
          hr_e.FIRST_NAME,
          hr_e.LAST_NAME,
          hr_e.EMAIL,
          hr_e.PHONE_NUMBER,
          hr_e.HIRE_DATE,
          hr_e.JOB_ID,
          hr_e.SALARY,
          hr_e.COMMISSION_PCT,
          hr_e.MANAGER_ID,
          hr_e.DEPARTMENT_ID)';

        WRITE_LOG(sysdate, 'INFO', SQL%ROWCOUNT || ' rows affected into emp2');
        UPDATE BM
        SET ST = 'N'
        WHERE ID = (SELECT max(id)
                    FROM BM);
        COMMIT;
      END IF;
      COMMIT;
    END;
    WRITE_LOG(sysdate, 'INFO', 'Finishing loading data');
    IF test_curr_id IS NOT NULL
    THEN
      EXECUTE IMMEDIATE 'DROP TABLE CURR_ID';
    END IF;
  END;