--1. For each employee show their salary and three
-- average salaries:
-- • for all employees,
-- • for their job
-- • for their department;
SELECT
  EMPLOYEE_ID,
  SALARY,
  round(avg(SALARY)
        OVER (), 2)                           all_emp_avg,
  round(avg(SALARY)
        OVER (PARTITION BY JOB_ID), 2)        job_avg,
  round(avg(SALARY)
        OVER (PARTITION BY DEPARTMENT_ID), 2) dept_avg
FROM EMPLOYEES;

-- 1.1 For each employee show average salary of people
-- hired in the same year.
SELECT
  LAST_NAME,
  extract(YEAR FROM HIRE_DATE)                               yyyy,
  round(avg(SALARY)
        OVER (PARTITION BY extract(YEAR FROM HIRE_DATE)), 2) avg_year_sal
FROM EMPLOYEES
ORDER BY extract(YEAR FROM HIRE_DATE);

--2. List the first 5 most paid employees
--3.1.Typical top-N query can be understood as:
-- • return exactly N rows. If there's a "tail" - ignore it;
SELECT
  LAST_NAME,
  SALARY
FROM (
  SELECT
    LAST_NAME,
    SALARY,
    row_number()
    OVER (
      ORDER BY SALARY DESC) most_paid
  FROM EMPLOYEES)
WHERE most_paid <= 5;

-- • return all records with one of first N values;

SELECT
  LAST_NAME,
  SALARY
FROM (SELECT
        last_name,
        salary,
        dense_rank()
        OVER (
          ORDER BY salary DESC)
          most_paid
      FROM EMPLOYEES)
WHERE most_paid <= 5
ORDER BY SALARY DESC;

-- • return not more than N rows (if last value has tail - don't get
-- rows with last value);
SELECT
  LAST_NAME,
  SALARY
FROM (SELECT
        last_name,
        salary,
        count(SALARY)
        OVER (
          ORDER BY salary DESC
        RANGE UNBOUNDED PRECEDING)
          most_paid
      FROM EMPLOYEES)
WHERE most_paid <= 5;

-- • return N rows + tail if it exists;
SELECT
  LAST_NAME,
  SALARY
FROM (
  SELECT
    LAST_NAME,
    SALARY,
    rank()
    OVER (
      ORDER BY SALARY DESC) most_paid
  FROM EMPLOYEES)
WHERE most_paid <= 5;

--List the second 5 most paid employees.
-- 3.1.Typical top-N query can be understood as:
-- • return exactly N rows. If there's a "tail" - ignore it;
SELECT
  LAST_NAME,
  SALARY
FROM (
  SELECT
    LAST_NAME,
    SALARY,
    row_number()
    OVER (
      ORDER BY SALARY DESC) most_paid
  FROM EMPLOYEES)
WHERE most_paid BETWEEN 6 AND 10;

-- • return all records with one of first N values;
SELECT
  LAST_NAME,
  SALARY
FROM (SELECT
        LAST_NAME,
        SALARY,
        dense_rank()
        OVER (
          ORDER BY SALARY DESC) most_paid
      FROM EMPLOYEES)
WHERE most_paid BETWEEN 6 AND 10;

-- • return not more than N rows (if last value has tail - don't get
-- rows with last value);
SELECT
  LAST_NAME,
  SALARY
FROM (SELECT
        LAST_NAME,
        SALARY,
        count(*)
        OVER (
          ORDER BY SALARY DESC) most_paid
      FROM EMPLOYEES)
WHERE most_paid BETWEEN 6 AND 10;

-- • return N rows + tail if it exists;
SELECT
  LAST_NAME,
  SALARY
FROM (
  SELECT
    LAST_NAME,
    SALARY,
    rank()
    OVER (
      ORDER BY SALARY DESC) most_paid
  FROM EMPLOYEES)
WHERE most_paid BETWEEN 6 AND 10;

-- For each employee show their hire date, salary
-- and average salary of two people hired just before
-- him/her and three people hired just after.
SELECT
  LAST_NAME,
  HIRE_DATE,
  SALARY,
  round(avg(SALARY)
        OVER (
          ORDER BY HIRE_DATE ROWS BETWEEN 2 PRECEDING AND 3 FOLLOWING), 2) avg_sal
FROM EMPLOYEES;

--without current row
SELECT
  LAST_NAME,
  HIRE_DATE,
  SALARY,
  round((sum(SALARY)
         OVER (
           ORDER BY HIRE_DATE ROWS BETWEEN 2 PRECEDING AND 3 FOLLOWING) - SALARY)
        /
        (count(SALARY)
         OVER (
           ORDER BY HIRE_DATE ROWS BETWEEN 2 PRECEDING AND 3 FOLLOWING) - 1), 2) avg
FROM EMPLOYEES;

-- For each employee show total salary of people
-- hired 90 days just before or after them
SELECT
  LAST_NAME,
  SALARY,
  HIRE_DATE,
  round(avg(SALARY)
        OVER (
          ORDER BY HIRE_DATE RANGE BETWEEN 90 PRECEDING AND 90 FOLLOWING), 2) avg_sal
FROM EMPLOYEES;

-- 3.2 For each employee from EMPLOYEES table show last
-- name of the first employees hired in the same year and last
-- employee, hired in the same year.
SELECT DISTINCT
  extract(YEAR FROM HIRE_DATE)                                                                yyyy,
  first_value(LAST_NAME)
  OVER (PARTITION BY extract(YEAR FROM HIRE_DATE)
    ORDER BY HIRE_DATE, EMPLOYEE_ID)                                                          first_emp,
  last_value(LAST_NAME)
  OVER (PARTITION BY extract(YEAR FROM HIRE_DATE)
    ORDER BY HIRE_DATE, EMPLOYEE_ID ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) last_emp
FROM EMPLOYEES
ORDER BY yyyy;

-- 3.3 For each employee, show comma-separated list of people
-- managed by the same manager.
SELECT
  LAST_NAME                      ln,
  listagg(LAST_NAME, ', ')
  WITHIN GROUP (
    ORDER BY LAST_NAME)
  OVER (PARTITION BY MANAGER_ID) coworkers
FROM EMPLOYEES;

-- 3.4 Select 20% of least-paid people from EMPLOYEES table.
SELECT
  LAST_NAME,
  SALARY
FROM (SELECT
        LAST_NAME,
        SALARY,
        percent_rank()
        OVER (
          ORDER BY SALARY DESC) cd
      FROM EMPLOYEES)
WHERE cd >= 0.8;

-- 4.1 create table T_JOB_HISTORY as
-- select employee_id, start_date , job_id , department_id
-- from JOB_HISTORY;
-- For each employee show the start and the end date of being on the position
-- ( show today as end date if the position is currently taken up).
SELECT
  EMPLOYEE_ID,
  JOB_ID,
  START_DATE,
  lead(START_DATE, 1, current_date)
  OVER (PARTITION BY EMPLOYEE_ID
    ORDER BY START_DATE) end_date
FROM T_JOB_HISTORY
ORDER BY EMPLOYEE_ID;

-- 5.1 Table TUMBLER stores "turn on" and "turn off" events for
-- some machine:
-- •EVENT_TIME - date and time of event
-- •EVENT_TYPE - "ON" of "OFF"
-- Calculate how much time (in days) machine were ON and
-- OFF during period represented in TUMBLER table
-- •Note: "ON" event can be followed by "OFF" event only and
-- vice versa.

CREATE TABLE TUMBLER (
  event_time DATE DEFAULT current_date,
  event_type VARCHAR2(3) CHECK (event_type IN ('ON', 'OFF'))
);

INSERT INTO TUMBLER
  SELECT
    '01.01.2012',
    'ON'
  FROM DUAL
  UNION ALL

  SELECT
    '17.01.2012',
    'OFF'
  FROM DUAL
  UNION ALL
  SELECT
    '19.01.2012',
    'ON'
  FROM dual
  UNION ALL
  SELECT
    '28.02.2012',
    'OFF'
  FROM DUAL
  UNION ALL
  SELECT
    '02.03.2012',
    'ON'
  FROM dual;

SELECT DISTINCT
  event_type,
  round(sum(end_mode - start_mode)
        OVER (PARTITION BY event_type)) duration
FROM (SELECT
        event_type,
        event_time             start_mode,
        lead(event_time, 1, current_date)
        OVER (
          ORDER BY event_time) end_mode
      FROM TUMBLER);