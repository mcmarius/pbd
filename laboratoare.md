## Laborator 1 - recapitulare SQL

Limbajele dintr-o bază de date:
- LDD/DDL: data definition language
  - `CREATE`
  - `ALTER`
  - `DROP`
  - `TRUNCATE`
- LMD/DML: data manipulation language
  - `INSERT`
  - `SELECT` (considerat și LID/DQL - data query language)
  - `UPDATE`
  - `DELETE`
- LCD/DCL: data control language
  - `GRANT`
  - `REVOKE`
- Tranzacții (uneori LCT/TCL - transaction control language)
  - `COMMIT`
  - `ROLLBACK`
  - savepoints
  - `LOCK` (până la încheierea tranzacției)

Interogări:
- `FROM`, `JOIN`, `WITH` (CTEs - common table expressions)
- `WHERE`
- funcții de grup (sau de agregare), `GROUP BY`, `DISTINCT`
- `HAVING`
- funcții analitice (window functions)
  - exemplu: top 5 cele mai mari salarii din fiecare departament

```sql
SELECT *
FROM (
    SELECT
        first_name,
        last_name,
        salary,
        department_id,
        ROW_NUMBER() OVER (
            PARTITION BY department_id
            ORDER BY salary DESC
        ) AS nr
    FROM employees
    ORDER BY department_id, nr
) AS employees_ranked
WHERE nr <= 5;
```

- `ORDER BY`
- indexare
- paginare: `OFFSET`, `FETCH FIRST/NEXT n ROWS ONLY/WITH TIES` (SQL:2008)/`LIMIT`/`TOP`
  - plan de execuție

[`GO` din SQL Server](https://stackoverflow.com/questions/5450672) este echivalent cu separatorul `/` din Oracle.

#### Planuri de execuție

<details>
<summary>Oracle
  (documentație
  <a href="https://docs.oracle.com/en/database/oracle/oracle-database/21/sqlrf/EXPLAIN-PLAN.html">aici</a>
  și
  <a href="https://docs.oracle.com/en/database/oracle/oracle-database/21/tgsql/generating-and-displaying-execution-plans.html">aici</a>)
</summary>

  <pre lang="sql">
    EXPLAIN PLAN
    SET STATEMENT_ID='plan1'
    FOR
    SELECT *
    FROM employees;

    SELECT * FROM table(DBMS_XPLAN.DISPLAY('plan_table', 'plan1', 'all'));  </pre>
</details>

<details>
<summary>MariaDB/MySQL
  (documentație
  <a href="https://mariadb.com/kb/en/explain/">aici</a>
  și
  <a href="https://mariadb.com/kb/en/analyze-statement/">aici</a>,
  iar pentru MySQL
  <a href="https://dev.mysql.com/doc/refman/8.0/en/explain.html">aici</a>)
</summary>

  <pre lang="sql">
    EXPLAIN
    SELECT *
    FROM employees;

    ANALYZE
    SELECT *
    FROM employees;  </pre>
</details>

<details>
<summary>SQL Server
  (documentație
  <a href="https://docs.microsoft.com/en-us/sql/relational-databases/performance/execution-plans">aici</a>
  și
  <a href="https://docs.microsoft.com/en-us/sql/t-sql/statements/set-showplan-all-transact-sql">aici</a>)
</summary>

  <pre lang="sql">
    SET SHOWPLAN_ALL ON;
    -- sau
    -- SET SHOWPLAN_TEXT ON;
    SET NOEXEC ON;

    SELECT *
    FROM employees;

    SET NOEXEC OFF;
    SET SHOWPLAN_ALL OFF;
    -- SET SHOWPLAN_TEXT OFF;  </pre>
</details>

<details>
<summary>PostgreSQL
  (documentație <a href="https://www.postgresql.org/docs/current/sql-explain.html">aici</a>)
</summary>

  <pre lang="sql">
    EXPLAIN
    SELECT *
    FROM employees;

    EXPLAIN ANALYZE
    SELECT *
    FROM employees;

    EXPLAIN (ANALYZE, BUFFERS)
    SELECT *
    FROM employees;      </pre>
</details>

<details>
<summary>SQLite
  (documentație <a href="https://www.sqlite.org/eqp.html">aici</a>)
</summary>

  <pre lang="sql">
    EXPLAIN QUERY PLAN
    SELECT *
    FROM employees;  </pre>
</details>

## Laborator 2 - introducere în PL/SQL

Limbajul PL/SQL este o extensie a limbajului SQL pentru a adăuga elemente procedurale, dar și alte facilități:
- instrucțiuni decizionale: `IF`, `CASE`
- instrucțiuni repetitive: `LOOP`, `FOR`, `WHILE` (și `EXIT`, `CONTINUE`, `EXIT WHEN <cond>`)
- tipuri de date asociate unor tabele: `%TYPE` și `%ROWTYPE`
- cursoare
- funcții și proceduri
- declanșatori
- pachete
- excepții

Limbajul PL/SQL a fost introdus de Oracle, la vremea respectivă având monopol asupra pieței. Pe baza acestui limbaj s-a încercat standardizarea acestor extensii în SQL/PSM. În practică, fiecare SGBD a implementat partea procedurală în manieră proprie și există numeroase incompatibilități.

PostgreSQL oferă limbajul PL/PgSQL, destul de asemănător ca sintaxă cu PL/SQL. Totuși, comportamentul diferă între cele două în anumite cazuri limită. Impresia mea este că PL/PgSQL este mai permisiv ca sintaxă și că implementează diverse facilități în plus (de exemplu, sunt permise comenzi DDL).

SQL Server oferă limbajul T-SQL (Transact-SQL). Sintaxa diferă ceva mai mult față de PL/SQL, dar la nivel de funcționalități, limbajele sunt asemănătoare.

MySQL pare un pic mai limitat la acest capitol față de MariaDB. Probabil că Oracle nu are motive să investească multe resurse în dezvoltarea MySQL pentru că și-ar face concurență la SGBD-ul comercial.

#### Cel mai simplu program

<details>
<summary>Oracle</summary>
  <pre lang="sql">
    BEGIN
        NULL;
    END;  </pre>
</details>

<details>
<summary>PostgreSQL</summary>
  <pre lang="sql">
    DO $$
    BEGIN
    END $$; </pre>
  Cel mai cel mai scurt ar fi ca mai jos, dar preferăm în majoritatea cazurilor varianta cu <code>$$</code> ca să nu avem probleme cu escapes.

  <pre lang="sql">
    DO 'BEGIN END'; </pre>
</details>

<details>
<summary>SQL Server</summary>
  <pre lang="sql">
    BEGIN
        RETURN;
    END;  </pre>
</details>

<details>
<summary>MariaDB</summary>
  <pre lang="sql">
    BEGIN NOT ATOMIC
    END;  </pre>
</details>

#### Hello, world!

<details>
<summary>Oracle</summary>
  În editorul de SQL trebuie să verificați să aveți activate mesajele de la server. În SQL Developer, <code>SET SERVEROUTPUT ON;</code>.
  <pre lang="sql">
    BEGIN
        DBMS_OUTPUT.PUT_LINE('Hello, world!');
    END;  </pre>
</details>

<details>
<summary>PostgreSQL</summary>
  <pre lang="sql">
    DO $$
    BEGIN
        RAISE NOTICE 'Hello, world!';
    END $$; </pre>
</details>

<details>
<summary>SQL Server</summary>
  <pre lang="sql">
    BEGIN
        PRINT 'Hello, world!';
    END;  </pre>
</details>

<details>
<summary>MariaDB</summary>
  <pre lang="sql">
    BEGIN NOT ATOMIC
        SELECT 'Hello, world!';
    END;  </pre>
  O altă variantă este cu redirecționarea într-un fișier de output:
  <pre lang="sql">
    BEGIN NOT ATOMIC
        SELECT 'Hello, world!' INTO OUTFILE '/tmp/mariadb-debug.log';
    END;  </pre>
  Este necesară acordarea de către admin a dreptului <code>FILE</code>: <code>GRANT FILE ON *.* TO seria36;</code>, iar apoi restart la server.
<br>
  Nu îmi este clar din documentație dacă se poate mai ok altfel. Altă variantă este cu setarea variabilei <code>SET SQL_MODE='ORACLE';</code> (detalii <a href="https://mariadb.com/kb/en/sql_modeoracle/">aici</a>) și cod de PL/SQL din Oracle.
</details>

#### Exemplu mai elaborat

<details>
<summary>Oracle</summary>
  <pre lang="sql">
    DECLARE
        x int := 2; -- nu merge cu = simplu la atribuiri
        j int;
        nume employees.first_name%TYPE;
        ang employees%ROWTYPE;
    BEGIN
        SELECT COUNT(*)
        INTO x
        FROM EMPLOYEES e;
        --WHERE 1 = 0;
        --
        IF x < 0 THEN
            DBMS_OUTPUT.PUT_LINE('x este ' || x);
        ELSIF x > 1 THEN
            -- nu avem ELSEIF în Oracle
            DBMS_OUTPUT.PUT_LINE('x chiar este ' || x);
        ELSE
            DBMS_OUTPUT.PUT_LINE('altceva');
        END IF;
        --
        CASE x
        WHEN 2 THEN DBMS_OUTPUT.PUT_LINE('2');
        WHEN 1 THEN DBMS_OUTPUT.PUT_LINE('1');
        ELSE        DBMS_OUTPUT.PUT_LINE('case 1 altceva');
        END CASE;
        --
        CASE
        WHEN x > 4 THEN          DBMS_OUTPUT.PUT_LINE('4');
        WHEN MOD(x, 3) <> 1 THEN DBMS_OUTPUT.PUT_LINE('3');
        ELSE                     DBMS_OUTPUT.PUT_LINE('case 2 altceva');
        END CASE;
        --
        -- eroare: TOO_MANY_ROWS
        -- SELECT first_name
        -- INTO nume
        -- FROM employees;
        -- DBMS_OUTPUT.PUT_LINE('numele este ' || nume);
        --
        SELECT first_name
        INTO nume
        FROM employees
        WHERE employee_id = 123;
        DBMS_OUTPUT.PUT_LINE('numele este ' || nume);
        --
        -- eroare: NO_DATA_FOUND
        -- SELECT first_name
        -- INTO nume
        -- FROM employees
        -- WHERE employee_id = 0;
        -- DBMS_OUTPUT.PUT_LINE('numele este ' || nume);
        --
        SELECT *
        INTO ang
        FROM employees
        WHERE employee_id = 123;
        DBMS_OUTPUT.PUT_LINE(
            'numele: ' || ang.first_name ||
            ', salariul: ' || ang.salary
        );
        --
        -- comenzile DDL nu merg în Oracle
        -- CREATE TABLE IF NOT EXISTS tbl(id int);
        -- DROP TABLE tbl;
        --
        -- incrementare/decrementare doar cu pas 1
        FOR i IN 1..x LOOP
            CONTINUE WHEN i < 2;
            EXIT WHEN i > 7;
            DBMS_OUTPUT.PUT_LINE('for loop i: ' || i || ' ' || sysdate);
        END LOOP;
        --
        FOR i IN REVERSE 1..5 LOOP
            DBMS_OUTPUT.PUT_LINE('forr loop i: ' || i);
        END LOOP;
        --
        j := 0;
        LOOP
            j := j + 3;
            EXIT WHEN j > 8;
            DBMS_OUTPUT.PUT_LINE('loop j: ' || j);
        END LOOP;
        --
        WHILE j > 0 LOOP
            j := j - 2;
            DBMS_OUTPUT.PUT_LINE('while loop j: ' || j);
        END LOOP;
    END;  </pre>
</details>

<details>
<summary>PostgreSQL</summary>
  <pre lang="sql">
    DO $$
    DECLARE
        x int = 2; -- sau cu :=
        j int;
        nume employees.first_name%TYPE;
        ang employees%ROWTYPE;
    BEGIN
        SELECT COUNT(*)
        INTO x
        FROM EMPLOYEES e;
        --WHERE 1 = 0;
        --
        IF x < 0 THEN
            RAISE NOTICE 'x este %', x;
        ELSEIF x > 1 THEN
            -- sau ELSIF pentru compatibilitate cu Oracle
            RAISE NOTICE 'x chiar este %', x;
        ELSE
            RAISE NOTICE 'altceva';
        END IF;
        --
        CASE x
        WHEN 2 THEN RAISE NOTICE '2';
        WHEN 1 THEN RAISE NOTICE '1';
        ELSE        RAISE NOTICE 'case 1 altceva';
        END CASE;
        --
        CASE
        WHEN x > 4 THEN          RAISE NOTICE '4';
        WHEN MOD(x, 3) <> 1 THEN RAISE NOTICE '3';
        ELSE                     RAISE NOTICE 'case 2 altceva';
        END CASE;
        --
        -- ia primul rând
        SELECT first_name
        INTO nume
        FROM employees;
        RAISE NOTICE 'numele este %', nume;
        --
        SELECT first_name
        INTO nume
        FROM employees
        WHERE employee_id = 123;
        RAISE NOTICE 'numele este %', nume;
        --
        -- setează variabila cu NULL
        SELECT first_name
        INTO nume
        FROM employees
        WHERE employee_id = 0;
        RAISE NOTICE 'numele este %', nume;
        --
        SELECT *
        INTO ang
        FROM employees
        WHERE employee_id = 123;
        RAISE NOTICE 'numele: %, salariul: %',
                     ang.first_name, ang.salary;
        --
        -- comenzile DDL merg în Postgres
        CREATE TABLE IF NOT EXISTS tbl(id int);
        DROP TABLE tbl;
        --
        FOR i IN 1..x BY 2 LOOP
            CONTINUE WHEN i < 2;
            EXIT WHEN i > 8;
            RAISE NOTICE 'for loop i: %, %', i, now();
        END LOOP;
        --
        -- la for reverse, limitele nu sunt ca în Oracle
        FOR i IN REVERSE 5..1 LOOP
            RAISE NOTICE 'forr loop i: %', i;
        END LOOP;
        --
        j = 0;
        LOOP
            j = j + 1;
            EXIT WHEN j > 4;
            RAISE NOTICE 'loop j: %', j;
        END LOOP;
        --
        WHILE j > 0 LOOP
            j = j - 1;
            RAISE NOTICE 'while loop j: %', j;
        END LOOP;
    END $$;  </pre>
</details>

<details>
<summary>SQL Server</summary>
  <pre lang="sql">
    BEGIN
        -- instrucțiunile DECLARE pot fi și în afara blocurilor BEGIN/END
        DECLARE @x int,
                @j int;
        DECLARE @nume VARCHAR(20);
        -- nu avem (echivalent) %TYPE sau %ROWTYPE în SQL Server
        -- nume employees.first_name%TYPE;
        -- ang employees%ROWTYPE;
        --
        -- exemplu SELECT în variabilă
        SET @x = (SELECT COUNT(*)
        FROM EMPLOYEES e
        -- WHERE 1 = 0
        );
        PRINT @x;
        --
        -- exemplu IF/ELSE
        IF @x < 0 -- nu avem THEN
            PRINT 'x este ' + ltrim(str(@x));
        ELSE
        BEGIN
            IF @x > 1
                -- nu avem ELSEIF/ELSIF/ELIF în SQL Server
                PRINT 'x chiar este ' + ltrim(str(@x));
            ELSE
                PRINT 'altceva';
        END; -- nu avem END IF
        --
        -- CASE merge doar în SELECT, nu și pentru instrucțiuni condiționale
        -- https://learn.microsoft.com/en-us/sql/t-sql/language-elements/case-transact-sql?view=sql-server-ver16#remarks
        --
        -- eroare: Subquery returned more than 1 value. This is not permitted when...
        -- SET @nume = (SELECT first_name
        -- FROM employees);
        -- PRINT 'numele este ' + @nume;
        --
        SET @nume = (SELECT first_name
        FROM employees
        WHERE employee_id = 123);
        PRINT 'numele este ' + @nume;
        --
        -- merge, dar variabila devine NULL dacă nu avem rânduri
        SET @nume = (SELECT first_name
        FROM employees
        WHERE employee_id = 0);
        -- fără COALESCE, întregul string se convertește la NULL și se afișează un rând gol
        PRINT 'numele este ' + COALESCE(@nume, '<null>');
        --
        -- nu avem echivalent de %ROWTYPE în SQL Server
        -- https://stackoverflow.com/questions/4022460/
        --
        -- comenzile DDL merg în SQL Server
        IF NOT EXISTS (
            SELECT *
            FROM INFORMATION_SCHEMA.TABLES
            WHERE TABLE_NAME = N'tbl'
        )
        BEGIN
            CREATE TABLE tbl(id int);
            DROP TABLE tbl;
        END;
        --
        -- nu există FOR LOOP în SQL Server
        -- nu există LOOP/END LOOP
        -- nu există DO-WHILE LOOP
        -- există GOTO
        -- https://stackoverflow.com/questions/6069024/
        -- https://learn.microsoft.com/en-us/sql/t-sql/language-elements/while-transact-sql
        --
        SET @j = 0;
        WHILE @j <= 12
        BEGIN
            SET @j = @j + 3;
            PRINT 'asc while loop j: ' + ltrim(str(@j));
            IF @j > 8
                BREAK;
        END;
        --
        WHILE @j > 0 
        BEGIN
            SET @j = @j - 2;
            PRINT 'desc while loop j: ' + ltrim(str(@j));
        END;
    END;  </pre>
</details>

<details>
<summary>MariaDB</summary>
  <pre lang="sql">
    BEGIN NOT ATOMIC
        -- TBA
    END;  </pre>
</details>


## Laborator 3 - colecții

#### Tipuri de date noi

Unele baze de date ne permit definirea de noi tipuri de date, asemănător cu structurile din C.
Nu putem avea câmpuri cu `%TYPE` (sau `%ROWTYPE`). În Oracle, deși nu crapă la crearea tipului, primim erori ulterior.

Observăm că aceste tipuri de date pot fi folosite atât în SQL, cât și în limbaj procedural.

<details>
<summary>Oracle (documentație <a href="https://docs.oracle.com/en/database/oracle/oracle-database/21/lnpls/CREATE-TYPE-statement.html">aici</a>)</summary>
  <pre lang="sql">
    CREATE OR REPLACE TYPE tip_test AS OBJECT (
        id int,
        nume VARCHAR2(50)
    );
    --
    DROP TYPE tip_test;
    --
    SELECT tip_test(1, 't') FROM dual;
    --
    DECLARE
        emp1 tip_test;
        emp2 tip_test := tip_test(0, '');
    BEGIN
        -- în această variantă trebuie apelat constructorul
        SELECT tip_test(employee_id, first_name)
        INTO emp1
        FROM EMPLOYEES
        WHERE EMPLOYEE_ID = 123;
        --
        -- dacă specificăm câmpurile explicit, variabila trebuie inițializată înainte
        SELECT employee_id, FIRST_NAME
        INTO emp2.id, emp2.nume
        FROM EMPLOYEES
        WHERE EMPLOYEE_ID = 123;
        --
        DBMS_OUTPUT.PUT_LINE(emp1.id || ' ' || emp1.nume);
    END;  </pre>
</details>

<details>
<summary>PostgreSQL (documentație <a href="https://www.postgresql.org/docs/current/sql-createtype.html">aici</a>)</summary>
  <pre lang="sql">
    CREATE TYPE tip_test AS (
        id int,
        nume varchar
    );
    --COMMIT;
    --
    DROP TYPE tip_test;
    --
    SELECT (1, 't')::tip_test;
    --
    DO $$
    DECLARE
        emp1 tip_test;
        emp2 tip_test; -- := (0, 'n/a')::tip_test;
    BEGIN
        -- nu este nevoie și nici nu merge cu cast
        SELECT employee_id, first_name
        INTO emp1
        FROM EMPLOYEES e
        WHERE EMPLOYEE_ID = 123;
        --
        SELECT employee_id, first_name
        INTO emp2.id, emp2.nume
        FROM EMPLOYEES
        WHERE EMPLOYEE_ID = 123;
        --
        RAISE NOTICE '% %', emp1.id, emp1.nume;
        RAISE NOTICE '% %', emp2.id, emp2.nume;
    END $$;  </pre>
</details>

SQL Server nu are un echivalent pentru `CREATE TYPE` ca cele de mai sus ([sursa](https://learn.microsoft.com/en-us/sql/t-sql/statements/create-type-transact-sql)).
Pot fi create tipuri de date asociate cu clase din .NET.

În MyQL/MariaDB nu este implementat deloc `CREATE TYPE` ([sursa](https://stackoverflow.com/questions/10266101/create-type-on-mysql)).

Se poate emula cu `CREATE TABLE` sau cu JSON.

#### Tablouri indexate

Tablourile indexate există doar în PL/SQL. Nu pot fi folosite în SQL.

#### Vectori de lungime fixă

Vectorii pot fi folosiți atât în SQL, cât și în limbaj procedural.

Oracle permite definirea unor vectori de lungime fixă.

În PostgreSQL, se poate crea ad-hoc un tip de date `ARRAY` de dimensiune variabilă pentru orice tip de date definit.
Dimensiunea nu trebuie specificată în prealabil ([sursa](https://www.postgresql.org/docs/current/arrays.html)).

În SQL Server poate fi folosit în schimb `TABLE`.

MySQL/MariaDB nu implementează arrays. Pot fi emulați cu tabele temporare sau cu JSON.

#### Tablouri imbricate

Tablourile imbricate pot fi emulate cu tabele temporare. Acestea există în SQL și în limbaj procedural.

<details>
<summary>Oracle</summary>
  <pre lang="sql">
    BEGIN
        -- TBA
        NULL;
    END;  </pre>
</details>

<details>
<summary>PostgreSQL</summary>
  <pre lang="sql">
    BEGIN
        -- TBA
    END;  </pre>
</details>

<details>
<summary>SQL Server</summary>
  <pre lang="sql">
    BEGIN
        -- TBA
        RETURN;
    END;  </pre>
</details>

<details>
<summary>MariaDB</summary>
  <pre lang="sql">
    BEGIN NOT ATOMIC
        -- TBA
    END;  </pre>
</details>

## Laborator 4 - colecții

TBA benchmarks. De văzut cu `t1 number := DBMS_UTILITY.get_time;`.

## Laborator 5 - cursoare
## Laborator 6 - cursoare
## Laborator 7 - funcții și proceduri

#### Pachete

Avem pachete (asemănătoare cu spațiile de nume din C++ și C#) în Oracle și [MariaDB](https://mariadb.com/kb/en/create-package/).
În PostgreSQL și [SQL Server](https://stackoverflow.com/questions/27833885/create-packages-in-sql-server-management-studio-without-ssis),
pachetele pot fi emulate cu ajutorul schemelor.

## Laborator 8 - declanșatori
## Laborator 9 - declanșatori
