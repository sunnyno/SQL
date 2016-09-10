CREATE TABLE t (
  x VARCHAR2(30)
);
INSERT ALL
INTO t VALUES ('XYZ123')
INTO t VALUES ('XYZ 123')
INTO t VALUES ('xyz 123')
INTO t VALUES ('X1Y2Z3')
INTO t VALUES ('123123')
INTO t VALUES ('?/*.')
INTO t VALUES ('\?.')
INTO t VALUES ('abc')
INTO t VALUES ('ABC')
INTO t VALUES ('123%ABC')
SELECT *
FROM DUAL;
SELECT *
FROM t;

--9.1 For each row in the table t (created early test table) print:
--Substring only with alpha characters
SELECT x
FROM t
WHERE regexp_like(x, '^[a-zA-Z]+$');

SELECT x
FROM t
WHERE regexp_like(x, '^[[:alpha:]]+$');

--second option is extract alpha characters from each row
SELECT
  x,
  regexp_replace(x, '[^[:alpha:]]+', '') substr_with_alpha
FROM t;

--third option is extract first substring matching the pattern from each row
SELECT
  x,
  regexp_substr(x, '[[:alpha:]]+') substr_with_alpha
FROM t;

--Substring only with digits
SELECT x
FROM t
WHERE regexp_like(x, '^[0-9]+$');

SELECT x
FROM t
WHERE regexp_like(x, '^[[:digit:]]+$');

--second option is extract digit characters from each row
SELECT
  x,
  regexp_replace(x, '[^[:digit:]]+', '') substr_with_alpha
FROM t;

--third option is extract first substring matching the pattern from each row
SELECT
  x,
  regexp_substr(x, '[[:digit:]]+') substr_with_alpha
FROM t;

--Substring only with punctuation characters
SELECT x
FROM t
WHERE regexp_like(x, '^[[:punct:]]+$');

--second option is extract punctuation characters from each row
SELECT
  x,
  regexp_replace(x, '[^[:punct:]]+', '') substr_with_alpha
FROM t;

--third option is extract first substring matching the pattern from each row
SELECT
  x,
  regexp_substr(x, '[[:punct:]]+') substr_with_alpha
FROM t;

--9.2 create tables row_data as
CREATE TABLE row_data AS
  SELECT phone_number || ',' || first_name || employee_id AS col
  FROM employees;

CREATE TABLE row_data2 AS
  SELECT phone_number || first_name || employee_id AS col
  FROM employees;

--Find the unique first names from row_data&row_data2.
SELECT names
FROM (SELECT
        count(names) ct,
        names
      FROM (SELECT regexp_substr(col, '[[:alpha:]]+') names
            FROM row_data)
      GROUP BY names)
WHERE ct = 1;

SELECT names
FROM (SELECT
        count(names) ct,
        names
      FROM (SELECT regexp_substr(col, '[[:alpha:]]+') names
            FROM row_data2)
      GROUP BY names)
WHERE ct = 1;


SELECT names
FROM (SELECT
        count(names) ct,
        names
      FROM (SELECT regexp_substr(col, '[[:alpha:]]+') names
            FROM row_data
            UNION ALL SELECT regexp_substr(col, '[[:alpha:]]+') names
                      FROM row_data2)
      GROUP BY names)
WHERE ct = 1;