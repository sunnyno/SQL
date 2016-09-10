CREATE USER HR_SPLIT IDENTIFIED BY HR_SPLIT;

GRANT CREATE SESSION TO HR_SPLIT;
GRANT CREATE ANY TABLE TO HR_SPLIT;
GRANT CREATE ANY PROCEDURE TO HR_SPLIT;
GRANT SELECT ON hr.employees TO HR_SPLIT;


CREATE TABLE EMP2 AS SELECT EMPLOYEE_ID,
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
                     WHERE 1 != 1;
ALTER TABLE EMP2
ADD CONSTRAINT emp2_pk PRIMARY KEY (employee_id);
CREATE TABLE EMP1 AS SELECT EMPLOYEE_ID,
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
                     WHERE 1 != 1;
ALTER TABLE EMP1
ADD CONSTRAINT emp1_pk PRIMARY KEY (employee_id);


CREATE GLOBAL TEMPORARY TABLE tmp_emp ON COMMIT DELETE ROWS
AS SELECT EMPLOYEE_ID,
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
   WHERE 1 != 1;

CREATE TABLE BM (
  id       NUMBER(10),
  st       CHAR(1) CHECK (st IN ('Y', 'N')),
  start_bm NUMBER(6) NOT NULL,
  end_bm   NUMBER(6)
);


create SEQUENCE bm_seq;

CREATE TABLE SP_LOG (
  id       NUMBER(10),
  datetime TIMESTAMP,
  res      VARCHAR2(5) CHECK (res IN ('INFO', 'ERROR')),
  message  VARCHAR2(300)
);

CREATE SEQUENCE log_sq;

CREATE OR REPLACE TRIGGER log_id_trig
BEFORE INSERT ON SP_LOG
FOR EACH ROW

BEGIN
  SELECT LOG_SQ.NEXTVAL
  INTO   :new.id
  FROM   dual;
END;


  CREATE OR REPLACE TRIGGER bm_id_trig
BEFORE INSERT ON BM
FOR EACH ROW

BEGIN
  SELECT bm_seq.NEXTVAL
  INTO   :new.id
  FROM   dual;
END;