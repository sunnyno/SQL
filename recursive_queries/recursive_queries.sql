--7.1 Select all subordinates of Steven King;
WITH subord(emp, lvl, emp_id) AS (
  SELECT
    LAST_NAME || ' ' || FIRST_NAME,
    1,
    EMPLOYEE_ID
  FROM EMPLOYEES
  WHERE LAST_NAME = 'King'
        AND FIRST_NAME = 'Steven'
  UNION ALL
  SELECT
    LAST_NAME || ' ' || FIRST_NAME,
    lvl + 1,
    EMPLOYEE_ID
  FROM EMPLOYEES
    INNER JOIN subord ON subord.emp_id = MANAGER_ID)
  SEARCH DEPTH FIRST BY emp ASC SET order_col
SELECT lpad(' ', (lvl - 1) * 3, '-') || emp AS subordinate
FROM subord;

--connect by
SELECT lpad(' ', (level - 1) * 3, '-') || LAST_NAME || ' ' || FIRST_NAME subord
FROM EMPLOYEES
CONNECT BY MANAGER_ID = PRIOR EMPLOYEE_ID
START WITH LAST_NAME = 'King' AND FIRST_NAME = 'Steven';

--7.2 Select all managers of employee with phone_number = '650.505.2876'. Don't show the actual employee.
WITH managers (emp, boss_id, lvl) AS (
  SELECT
    LAST_NAME || ' ' || FIRST_NAME,
    MANAGER_ID,
    1
  FROM EMPLOYEES
  WHERE PHONE_NUMBER = '650.505.2876'
  UNION ALL
  SELECT
    LAST_NAME || ' ' || FIRST_NAME,
    MANAGER_ID,
    lvl + 1
  FROM EMPLOYEES
    JOIN managers ON managers.boss_id = EMPLOYEE_ID
)
  SEARCH DEPTH FIRST BY emp ASC SET order_col
SELECT lpad(' ', (lvl - 2) * 3, '-') || emp AS manager
FROM managers
WHERE lvl > 1;

--connect by
SELECT lpad(' ', (level - 2) * 3, '-') || LAST_NAME || ' ' || FIRST_NAME subord
FROM EMPLOYEES
WHERE level > 1
CONNECT BY PRIOR MANAGER_ID = EMPLOYEE_ID
START WITH PHONE_NUMBER = '650.505.2876';

-- 7.3 For each 'Programmer' show list of his/her managers
-- • from top to bottom (like 'King/..../TheProgrammer').

WITH subord_manager (sub, boss, emp_id) AS (
  SELECT
    e.LAST_NAME || ' ' || e.FIRST_NAME,
    m.LAST_NAME || ' ' || m.FIRST_NAME || '/' || e.LAST_NAME || ' ' || e.FIRST_NAME,
    e.EMPLOYEE_ID
  FROM EMPLOYEES e
    JOIN EMPLOYEES m ON e.MANAGER_ID = m.EMPLOYEE_ID
  WHERE m.MANAGER_ID IS NULL
  UNION ALL
  SELECT
    e.LAST_NAME || ' ' || e.FIRST_NAME,
    boss || '/' || e.LAST_NAME || ' ' || e.FIRST_NAME,
    e.EMPLOYEE_ID
  FROM EMPLOYEES e
  JOIN subord_manager m ON e.MANAGER_ID = m.emp_id
)
SELECT
  sub,
  boss
FROM subord_manager
JOIN EMPLOYEES ON subord_manager.emp_id = EMPLOYEE_ID
JOIN JOBS ON EMPLOYEES.JOB_ID = JOBS.JOB_ID
WHERE JOB_TITLE = 'Programmer';

--connect by
SELECT
  LAST_NAME || ' ' || FIRST_NAME                           sub,
  sys_connect_by_path(LAST_NAME || ' ' || FIRST_NAME, '/') boss_to_sub
FROM EMPLOYEES
  JOIN JOBS ON EMPLOYEES.JOB_ID = JOBS.JOB_ID
WHERE JOB_TITLE = 'Programmer'
CONNECT BY MANAGER_ID = PRIOR EMPLOYEE_ID
START WITH MANAGER_ID IS NULL;

-- • from bottom to top (‘TheProgrammer/…/ King’)
WITH subord_manager (sub, boss, m_id, e_id) AS (
  SELECT
    m.LAST_NAME || ' ' || m.FIRST_NAME,
    m.LAST_NAME || ' ' || m.FIRST_NAME || '/' || e.LAST_NAME || ' ' || e.FIRST_NAME,
    e.MANAGER_ID,
    e.EMPLOYEE_ID
  FROM EMPLOYEES e
  JOIN EMPLOYEES m ON e.EMPLOYEE_ID = m.MANAGER_ID
  JOIN JOBS ON m.JOB_ID = JOBS.JOB_ID
  WHERE JOB_TITLE = 'Programmer'
  UNION ALL
  SELECT
    sub,
    boss || '/' || e.LAST_NAME || ' ' || e.FIRST_NAME,
    e.MANAGER_ID,
    e.EMPLOYEE_ID
  FROM EMPLOYEES e
    JOIN subord_manager m ON e.EMPLOYEE_ID = m.m_id
)
SELECT
  sub,
  boss
FROM subord_manager
JOIN EMPLOYEES ON subord_manager.e_id = EMPLOYEE_ID
WHERE m_id IS NULL;

--connect by
SELECT
  CONNECT_BY_ROOT LAST_NAME || ' ' || FIRST_NAME           sub,
  sys_connect_by_path(LAST_NAME || ' ' || FIRST_NAME, '/') sub_to_boss
FROM EMPLOYEES
  JOIN JOBS ON EMPLOYEES.JOB_ID = JOBS.JOB_ID
WHERE MANAGER_ID IS NULL
CONNECT BY PRIOR MANAGER_ID = EMPLOYEE_ID
START WITH JOB_TITLE = 'Programmer';

--7.4 List all second-level subordinates of Steven King (direct subordinates are first-level subordinates).
WITH second_lvl_King_sub (sub, lvl, e_id ) AS (
  SELECT
    LAST_NAME || ' ' || FIRST_NAME,
    1,
    EMPLOYEE_ID
  FROM EMPLOYEES
  WHERE LAST_NAME = 'King'
        AND FIRST_NAME = 'Steven'
  UNION ALL
  SELECT
    LAST_NAME || ' ' || FIRST_NAME,
    lvl + 1,
    EMPLOYEE_ID
  FROM EMPLOYEES
  JOIN second_lvl_King_sub ON second_lvl_King_sub.e_id = MANAGER_ID)
  SEARCH DEPTH FIRST BY sub ASC SET order_col
SELECT sub
FROM second_lvl_King_sub
WHERE lvl = 3
ORDER BY sub;

--connect by
SELECT LAST_NAME || ' ' || FIRST_NAME second_sub
FROM EMPLOYEES
WHERE level = 3
CONNECT BY MANAGER_ID = PRIOR EMPLOYEE_ID
START WITH LAST_NAME = 'King' AND FIRST_NAME = 'Steven'
ORDER BY second_sub;

--7.5 For each employee show his/her salary and summary salary of all his managers. Preserve tree structure in output.
WITH emp_sal (emp, sal, m_sal, e_id, m_id, lvl) AS (
  SELECT
    LAST_NAME || ' ' || FIRST_NAME,
    SALARY,
    SALARY,
    EMPLOYEE_ID,
    MANAGER_ID,
    1
  FROM EMPLOYEES
  UNION ALL
  SELECT
    emp,
    sal,
    m_sal + SALARY,
    EMPLOYEE_ID,
    MANAGER_ID,
    lvl + 1
  FROM EMPLOYEES
  JOIN emp_sal ON m_id = EMPLOYEE_ID
)
  SEARCH DEPTH FIRST BY e_id ASC SET ord_col
SELECT
  lpad(' ', (lvl - 1) * 3, '-') || emp AS emp,
  sal,
  m_sal
FROM emp_sal
WHERE m_id IS NULL;

--connect by
SELECT
  lpad(' ', (level - 1) * 3, '-') || LAST_NAME || ' ' || FIRST_NAME name,
  SALARY,
  (SELECT sum(e2.SALARY)
   FROM EMPLOYEES e2
   START WITH e2.EMPLOYEE_ID = e1.EMPLOYEE_ID
   CONNECT BY PRIOR e2.MANAGER_ID = e2.EMPLOYEE_ID)                 sum_sal
FROM EMPLOYEES e1
START WITH e1.MANAGER_ID IS NULL
CONNECT BY PRIOR EMPLOYEE_ID = MANAGER_ID;

--7.6 Generate list of dates from sysdate to last day of the year (no hardcode)
WITH dates (today, lvl) AS (
  SELECT
    to_char(sysdate, 'DD-MM-YYYY'),
    1
  FROM dual
  UNION ALL
  SELECT
    to_char(TO_DATE(sysdate, 'DD-MM-YYYY') + lvl, 'DD-MM-YYYY'),
    lvl + 1
  FROM dates
  WHERE TO_DATE(today, 'DD-MM-YYYY') <
        to_date(last_day(add_months(sysdate, 12 - to_number(to_char(sysdate, 'mm')))), 'DD-MM-YYYY')
)
SELECT today
FROM dates;

--connect by
SELECT to_char(sysdate + LEVEL - 1, 'DD-MM-YYYY') today
FROM DUAL
CONNECT BY sysdate + LEVEL - 1 <= last_day(add_months(sysdate, 12 - to_number(to_char(sysdate, 'mm'))));

--8.1 Find the manager with only one subordinate, who, in turn, has no subordinates.
SELECT name
FROM (
  SELECT
    LAST_NAME || ' ' || FIRST_NAME               name,
    (SELECT count(e2.employee_id) - 1
     FROM EMPLOYEES e2

     CONNECT BY e2.MANAGER_ID = PRIOR e2.EMPLOYEE_ID
     START WITH e1.EMPLOYEE_ID = e2.EMPLOYEE_ID) sub_quant,
    lead(CONNECT_BY_ISLEAF)
    OVER (
      ORDER BY ROWNUM)                           has_subs
  FROM EMPLOYEES e1

  CONNECT BY MANAGER_ID = PRIOR EMPLOYEE_ID
  START WITH MANAGER_ID IS NULL
)
WHERE sub_quant = 1 AND has_subs = 1;

--8.2 Find the amount of direct and indirect subordinates for each manager.
SELECT
  name,
  direct,
  sub_quant - direct indirect
FROM (
  SELECT
    LAST_NAME || ' ' || FIRST_NAME               name,
    (SELECT count(EMPLOYEE_ID)
     FROM EMPLOYEES e3
     WHERE e1.EMPLOYEE_ID = e3.MANAGER_ID
     GROUP BY MANAGER_ID)                        direct,
    (SELECT count(e2.employee_id) - 1
     FROM EMPLOYEES e2

     CONNECT BY e2.MANAGER_ID = PRIOR e2.EMPLOYEE_ID
     START WITH e1.EMPLOYEE_ID = e2.EMPLOYEE_ID) sub_quant
  FROM EMPLOYEES e1
)
WHERE sub_quant <> 0;

--8.3 Write SQL query that will generate first 50 numbers in Fibonacci series.
WITH fib (num, next, lvl) AS (
  SELECT
    1,
    1,
    1
  FROM DUAL
  UNION ALL
  SELECT
    num + next,
    last_value(num)
    OVER (
      ORDER BY ROWNUM),
    lvl + 1
  FROM fib
  WHERE lvl < 50
) SELECT num
  FROM fib;

-- 8.4 Table TheString contains one row and one field called str.
-- This field stores some arithmetical expression with numbers,
-- arithmetic signs and parenthesis’s. For example, “2*((5+7)+2*(2+3))*8)+9”.
-- Write a query that will return each symbol from the string as a separate row.
CREATE TABLE TheString AS SELECT '2*((5+7)+2*(2+3))*8)+9' AS str
                          FROM dual;

SELECT substr(str, level, 1)
FROM TheString
CONNECT BY substr(str, level, 1) IS NOT NULL;

--8.5 The table contains the ordered set or numbers, for example (3, 6, 8, 9, 11 , …).
--  Return three smallest missing numbers (4, 5, 7).
CREATE TABLE NumberSet AS SELECT DISTINCT round(dbms_random.value(1, 100)) num
                          FROM dual
                          CONNECT BY LEVEL <= 30
                          ORDER BY num;


SELECT miss
FROM (SELECT DISTINCT CASE WHEN num - level <> num AND num + level NOT IN (SELECT num
                                                                           FROM NumberSet)
                                AND ROWNUM <= 4
  THEN num + level END miss
      FROM NumberSet
      CONNECT BY ROWNUM <= 3
      ORDER BY miss)
WHERE miss IS NOT NULL;

--some extra tasks
--•Find the duration off all routes from Lviv (tables train  cities)
WITH routes(city, duration, route) AS (
  SELECT
    destination,
    duration_min,
    origin || '/' || destination
  FROM trains
  WHERE origin = 'Lviv'
  UNION ALL
  SELECT
    destination,
    duration + duration_min,
    route || '/' || destination
  FROM trains
    JOIN routes ON trains.origin = routes.city
)
SELECT
  route,
  duration
FROM routes;

-- Find the cheapest and the shortest way from Kyiv to Budapest
WITH routes(city, duration, route) AS (
  SELECT
    destination,
    duration_min,
    origin || '/' || destination
  FROM trains
  WHERE origin = 'Kyiv'
  UNION ALL
  SELECT
    destination,
    duration + duration_min,
    route || '/' || destination
  FROM trains
    JOIN routes ON trains.origin = routes.city
)
SELECT city,
  duration,
  route
FROM routes
WHERE duration IN (SELECT min(duration)
                   FROM routes
                   WHERE city = 'Budapest');