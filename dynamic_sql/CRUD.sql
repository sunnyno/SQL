-----------------------CRUD------------------------
CREATE TABLE employees_for_crud AS SELECT
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
                                   FROM EMPLOYEES;

CREATE OR REPLACE PACKAGE CRUD IS
  PROCEDURE create_urd(emp_id  employees_for_crud.employee_id%TYPE DEFAULT -1,
                       first_n employees_for_crud.first_name%TYPE DEFAULT 'Unknown',
                       last_n  employees_for_crud.last_name%TYPE DEFAULT 'Unknown',
                       em      employees_for_crud.email%TYPE DEFAULT 'Unknown',
                       phone   employees_for_crud.phone_number%TYPE DEFAULT 'Unknown',
                       hire    employees_for_crud.hire_date%TYPE DEFAULT to_date('1900-01-01', 'yyyy-mm-dd'),
                       job     employees_for_crud.job_id%TYPE DEFAULT 'Unknown',
                       sal     employees_for_crud.SALARY%TYPE DEFAULT -1.00,
                       comm    employees_for_crud.COMMISSION_PCT%TYPE DEFAULT 0.00,
                       manager employees_for_crud.MANAGER_ID%TYPE DEFAULT 0,
                       dept    employees_for_crud.DEPARTMENT_ID%TYPE DEFAULT -1);
  FUNCTION c_read_ud(emp_id employees_for_crud.employee_id%TYPE)
    RETURN employees_for_crud%ROWTYPE;
  PROCEDURE cr_update_d(emp_id  employees_for_crud.employee_id%TYPE DEFAULT -1,
                        first_n employees_for_crud.first_name%TYPE DEFAULT NULL,
                        last_n  employees_for_crud.last_name%TYPE DEFAULT NULL,
                        em      employees_for_crud.email%TYPE DEFAULT NULL,
                        phone   employees_for_crud.phone_number%TYPE DEFAULT NULL,
                        hire    employees_for_crud.hire_date%TYPE DEFAULT NULL,
                        job     employees_for_crud.job_id%TYPE DEFAULT NULL,
                        sal     employees_for_crud.SALARY%TYPE DEFAULT NULL,
                        comm    employees_for_crud.COMMISSION_PCT%TYPE DEFAULT NULL,
                        manager employees_for_crud.MANAGER_ID%TYPE DEFAULT NULL,
                        dept    employees_for_crud.DEPARTMENT_ID%TYPE DEFAULT NULL);
  PROCEDURE cru_delete(emp_id employees_for_crud.employee_id%TYPE);
END CRUD;

CREATE OR REPLACE PACKAGE BODY CRUD IS
  --create
  PROCEDURE create_urd(emp_id  employees_for_crud.employee_id%TYPE DEFAULT -1,
                       first_n employees_for_crud.first_name%TYPE DEFAULT 'Unknown',
                       last_n  employees_for_crud.last_name%TYPE DEFAULT 'Unknown',
                       em      employees_for_crud.email%TYPE DEFAULT 'Unknown',
                       phone   employees_for_crud.phone_number%TYPE DEFAULT 'Unknown',
                       hire    employees_for_crud.hire_date%TYPE DEFAULT to_date('1900-01-01', 'yyyy-mm-dd'),
                       job     employees_for_crud.job_id%TYPE DEFAULT 'Unknown',
                       sal     employees_for_crud.SALARY%TYPE DEFAULT -1.00,
                       comm    employees_for_crud.COMMISSION_PCT%TYPE DEFAULT 0.00,
                       manager employees_for_crud.MANAGER_ID%TYPE DEFAULT 0,
                       dept    employees_for_crud.DEPARTMENT_ID%TYPE DEFAULT -1) IS
    l_exists  NUMBER(1);
    l_manager employees_for_crud.MANAGER_ID%TYPE := manager;
    BEGIN
      SELECT CASE WHEN emp_id IN (SELECT EMPLOYEE_ID
                                  FROM employees_for_crud)
        THEN 1
             ELSE 0 END
      INTO l_exists
      FROM dual;
      IF l_exists = 0
      THEN
        IF manager = 0
        THEN SELECT EMPLOYEE_ID
             INTO l_manager
             FROM employees_for_crud
             WHERE MANAGER_ID IS NULL;
        END IF;
        INSERT INTO employees_for_crud
        VALUES (emp_id, first_n, last_n, em, phone, hire, job, sal, comm, l_manager, dept);
      ELSE
        DBMS_OUTPUT.put_line('Invalid ID');
      END IF;
    END create_urd;

  --read
  FUNCTION c_read_ud(emp_id employees_for_crud.employee_id%TYPE)
    RETURN employees_for_crud%ROWTYPE IS
    emp_rec employees_for_crud%ROWTYPE;
    BEGIN
      BEGIN
        SELECT
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
        INTO emp_rec
        FROM employees_for_crud
        WHERE employees_for_crud.EMPLOYEE_ID = emp_id;
        EXCEPTION WHEN NO_DATA_FOUND THEN DBMS_OUTPUT.put_line('No employee with id=' || emp_id);
        emp_rec := NULL;
      END;
      RETURN emp_rec;

    END c_read_ud;

  --update
  PROCEDURE cr_update_d(emp_id  employees_for_crud.employee_id%TYPE DEFAULT -1,
                        first_n employees_for_crud.first_name%TYPE DEFAULT NULL,
                        last_n  employees_for_crud.last_name%TYPE DEFAULT NULL,
                        em      employees_for_crud.email%TYPE DEFAULT NULL,
                        phone   employees_for_crud.phone_number%TYPE DEFAULT NULL,
                        hire    employees_for_crud.hire_date%TYPE DEFAULT NULL,
                        job     employees_for_crud.job_id%TYPE DEFAULT NULL,
                        sal     employees_for_crud.SALARY%TYPE DEFAULT NULL,
                        comm    employees_for_crud.COMMISSION_PCT%TYPE DEFAULT NULL,
                        manager employees_for_crud.MANAGER_ID%TYPE DEFAULT NULL,
                        dept    employees_for_crud.DEPARTMENT_ID%TYPE DEFAULT NULL) IS
    l_exists NUMBER(1);
    BEGIN
      SELECT CASE WHEN emp_id IN (SELECT EMPLOYEE_ID
                                  FROM employees_for_crud)
        THEN 1
             ELSE 0 END
      INTO l_exists
      FROM dual;
      IF l_exists = 1
      THEN
        UPDATE employees_for_crud
        SET FIRST_NAME   = nvl(first_n, (SELECT FIRST_NAME
                                         FROM employees_for_crud
                                         WHERE EMPLOYEE_ID = emp_id)),
          LAST_NAME      = nvl(last_n, (SELECT LAST_NAME
                                        FROM employees_for_crud
                                        WHERE EMPLOYEE_ID = emp_id)),
          EMAIL          = nvl(em, (SELECT EMAIL
                                    FROM employees_for_crud
                                    WHERE EMPLOYEE_ID = emp_id)),
          PHONE_NUMBER   = nvl(phone, (SELECT PHONE_NUMBER
                                       FROM employees_for_crud
                                       WHERE EMPLOYEE_ID = emp_id)),
          HIRE_DATE      = nvl(hire, (SELECT HIRE_DATE
                                      FROM employees_for_crud
                                      WHERE EMPLOYEE_ID = emp_id)),
          JOB_ID         = nvl(job, (SELECT JOB_ID
                                     FROM employees_for_crud
                                     WHERE EMPLOYEE_ID = emp_id)),
          SALARY         = nvl(sal, (SELECT SALARY
                                     FROM employees_for_crud
                                     WHERE EMPLOYEE_ID = emp_id)),
          COMMISSION_PCT = nvl(comm, (SELECT COMMISSION_PCT
                                      FROM employees_for_crud
                                      WHERE EMPLOYEE_ID = emp_id)),
          MANAGER_ID     = nvl(manager, (SELECT MANAGER_ID
                                         FROM employees_for_crud
                                         WHERE EMPLOYEE_ID = emp_id)),
          DEPARTMENT_ID  = nvl(dept, (SELECT DEPARTMENT_ID
                                      FROM employees_for_crud
                                      WHERE EMPLOYEE_ID = emp_id))
        WHERE EMPLOYEE_ID = emp_id;
      ELSE
        DBMS_OUTPUT.put_line('Invalid ID');
      END IF;
    END cr_update_d;

  --delete
  PROCEDURE cru_delete(emp_id employees_for_crud.employee_id%TYPE) IS
    l_exists NUMBER(1, 0);
    BEGIN
      SELECT CASE WHEN emp_id IN (SELECT EMPLOYEE_ID
                                  FROM employees_for_crud)
        THEN 1
             ELSE 0 END
      INTO l_exists
      FROM dual;
      IF l_exists = 1
      THEN
        DELETE FROM employees_for_crud
        WHERE EMPLOYEE_ID = emp_id;
      ELSE
        DBMS_OUTPUT.put_line('Invalid ID');
      END IF;
    END cru_delete;

END CRUD;