--6.1 Получить информацию о сотруднике с employee_id = 133.
-- Установить должность (v_job) равно продавец (saleman),
-- номер департамента (v_deptNo) равно 35 и комиссионные (v_comm) в размере 20% от зарплаты (v_sal),
-- если фамилия сотрудника Mallin
--Вывести результат (v_comm)
DECLARE
  l_employee employees%ROWTYPE;
  v_job      JOBS.JOB_TITLE%TYPE;
  v_deptno   EMPLOYEES.department_id%TYPE;
  v_comm     NUMBER(3); --getting EMPLOYEES.COMMISSION_PCT%TYPE which is number(2,2) invokes numeric error ;
  emp_id     EMPLOYEES.employee_id%TYPE := 133;

BEGIN
  SELECT EMPLOYEE_ID,
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
  INTO l_employee
  FROM employees
  WHERE EMPLOYEE_ID = emp_id;

  IF l_employee.last_name = 'Mallin'
  THEN
    v_job := 'salesman';
    v_deptno := 35;
    v_comm := trunc(l_employee.SALARY / 5);
    DBMS_OUTPUT.put_line('Commission: ' || v_comm);
  END IF;

END;


--6.2 Получить информацию о сотруднике с employee_id = 128.
--Установить должность (v_job) равно менеджер (Manager),
-- если фамилия сотрудника Mallin, иначе установить должность клерк (Clerk)
-- Вывести результат (v_job)
DECLARE
  l_employee  employees%ROWTYPE;
  v_job       JOBS.JOB_TITLE%TYPE;
  v_last_name EMPLOYEES.LAST_NAME%TYPE;
  emp_id      EMPLOYEES.employee_id%TYPE := 128;
BEGIN
  SELECT EMPLOYEE_ID,
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
  INTO l_employee
  FROM employees
  WHERE EMPLOYEE_ID = emp_id;

  IF l_employee.last_name = 'Mallin'
  THEN
    v_job := 'Manager';
  ELSE
    v_job := 'Clerk';
  END IF;
  DBMS_OUTPUT.put_line('Job: ' || v_job);
END;

--6.3 Объявить и инициализировать переменные перечисленные в следующем условии
--Если стартовое значение (v_start) меньше 50, то увеличить его в 2 раза
--Если стартовое значение в диапазоне от 50 до 100, то уменьшить в 1.5 раза
--Иначе уменьшить в 2 раза
--Вывести результат (v_start)
DECLARE
  v_start NUMBER := 20;
BEGIN
  IF (v_start < 50)
  THEN
    v_start := v_start * 2;
  ELSIF (v_start >= 50 AND v_start < 100)
    THEN
      v_start := v_start / 1.5;
  ELSE
    v_start := v_start / 2;
  END IF;
  DBMS_OUTPUT.put_line(v_start);
END;

--6.4. Написать блок всеми вариантами циклов для вывода чисел
--  от 100 до 110
-- от 110 до 90
-- ввести CONTINUE для печати четных чисел
-- EXIT для выхода по прошествии 5 итераций
DECLARE
  v_loop NUMBER(3, 0);
  v_beg  NUMBER(3, 0) := 100;
  v_mid  NUMBER(3, 0) := 110;
  v_end  NUMBER(2, 0) := 90;
  v_exit NUMBER(1, 0) := 5;
BEGIN
  --loop
  DBMS_OUTPUT.put_line('loop_cycles');
  v_loop := v_beg - 1;
  LOOP
    v_loop := v_loop + 1;
    EXIT WHEN v_loop = v_mid + 1 OR v_loop = v_beg + v_exit * 2;
    CONTINUE WHEN mod(v_loop, 2) <> 0;
    DBMS_OUTPUT.put_line(v_loop);
  END LOOP;

  DBMS_OUTPUT.put_line('_____________________');
  v_loop := v_mid + 1;
  LOOP
    v_loop := v_loop - 1;
    EXIT WHEN v_loop = v_end - 1 OR v_loop = v_mid - v_exit * 2;
    CONTINUE WHEN mod(v_loop, 2) = 1;
    DBMS_OUTPUT.put_line(v_loop);
  END LOOP;

  --while loop
  DBMS_OUTPUT.put_line('While cycles');
  v_loop := v_beg - 1;
  WHILE v_loop <= v_mid LOOP
    v_loop := v_loop + 1;
    EXIT WHEN v_loop = v_end - 1 OR v_loop = v_beg + v_exit * 2;
    CONTINUE WHEN mod(v_loop, 2) = 1;
    DBMS_OUTPUT.put_line(v_loop);
  END LOOP;

  DBMS_OUTPUT.put_line('_____________________');

  v_loop := v_mid + 1;
  WHILE v_loop >= v_end LOOP
    v_loop := v_loop - 1;
    EXIT WHEN v_loop = v_end - 1 OR v_loop = v_mid - v_exit * 2;
    CONTINUE WHEN mod(v_loop, 2) = 1;
    DBMS_OUTPUT.put_line(v_loop);
  END LOOP;

  --FOR loop
  DBMS_OUTPUT.put_line('For cycles');
  FOR v_loop IN v_beg..v_mid LOOP
    EXIT WHEN v_loop = v_beg + v_exit * 2;
    CONTINUE WHEN mod(v_loop, 2) = 1;
    DBMS_OUTPUT.put_line(v_loop);
  END LOOP;

  DBMS_OUTPUT.put_line('_______________');

  FOR v_loop IN REVERSE v_end..v_mid LOOP
    EXIT WHEN v_loop = v_mid - v_exit * 2;
    CONTINUE WHEN mod(v_loop, 2) = 1;
    DBMS_OUTPUT.put_line(v_loop);
  END LOOP;

END;