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
) employees_ranked  -- sau ) AS employees_ranked dacă nu suntem pe Oracle
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
  <a href="https://docs.oracle.com/en/database/oracle/oracle-database/23/sqlrf/EXPLAIN-PLAN.html">aici</a>
  și
  <a href="https://docs.oracle.com/en/database/oracle/oracle-database/23/tgsql/generating-and-displaying-execution-plans.html">aici</a>)
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

PostgreSQL oferă limbajul PL/PgSQL, destul de asemănător ca sintaxă cu PL/SQL. Totuși, comportamentul diferă între cele două în anumite cazuri limită. PL/PgSQL este mai permisiv ca sintaxă, iar comenzile DDL sunt mult mai ușor și natural de folosit decât în Oracle.

SQL Server oferă limbajul T-SQL (Transact-SQL). Sintaxa diferă ceva mai mult față de PL/SQL, dar la nivel de funcționalități, limbajele sunt asemănătoare.

MySQL pare un pic mai limitat la acest capitol față de MariaDB. Probabil că Oracle nu are motive să investească multe resurse în dezvoltarea MySQL pentru că și-ar face concurență la SGBD-ul comercial.

SQLite este cel mai limitat la acest capitol deoarece nu funcționează pe principiul client-server, având nativ doar declanșatori.
Pot fi adăugate [funcții proprii](https://www.sqlite.org/appfunc.html) din alte limbaje de programare sau cu ajutorul unor [extensii](https://github.com/nalgeon/sqlean).

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
        FROM employees;
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
        -- comenzile DDL nu merg direct în Oracle
        -- CREATE TABLE tbl(id int);
        -- DROP TABLE tbl;
        -- trebuie să folosim proceduri dedicate și cursoare; vezi la cursoare
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
        FROM employees;
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
        -- eroare
        -- SELECT first_name
        -- INTO STRICT nume
        -- FROM employees;
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
        SELECT COUNT(*)
        INTO j
        FROM tbl;
        RAISE NOTICE 'j este %', j;
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
            SET @j = (SELECT COUNT(*) FROM tbl);
            PRINT 'j este ' + ltrim(str(@j));
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
        -- întâi avem toate instrucțiunile de declare
        -- comentariile obligatoriu trebuie să aibă spațiu după --
        -- DECLARE stdout TEXT;  -- buffer pt simulat funcție de afișare
        DECLARE x DOUBLE;
        DECLARE j INT;
        -- doar în MariaDB >= 10.3; în MySQL nu avem așa ceva
        -- https://mariadb.com/kb/en/declare-variable/
        -- https://dev.mysql.com/doc/refman/8.1/en/declare-local-variable.html
        DECLARE nume TYPE OF employees.first_name;
        DECLARE ang ROW TYPE OF employees;
        -- merge cu %TYPE sau %ROWTYPE dacă setăm sql_mode=Oracle
        -- .
        -- https://stackoverflow.com/questions/273437/how-do-you-debug-mysql-stored-procedures
        -- DROP TABLE logs;
        CREATE TABLE IF NOT EXISTS logs (
            ts TIMESTAMP DEFAULT current_timestamp,
        msg VARCHAR(2048)
        ) ENGINE = myisam;
        TRUNCATE TABLE logs;
        -- SET stdout = '';
        SET x = 2; -- merge și cu :=
        -- exemplu SELECT în variabilă
        SELECT COUNT(*)
        INTO x
        FROM employees e;
        -- WHERE 1 = 0;
        -- .
        -- exemplu IF/ELSE
        IF x < 0 THEN
            -- SET stdout = CONCAT(stdout, 'x este ', x, '\n');
            INSERT INTO logs (msg) VALUES(CONCAT('x este ', x));
        ELSEIF x > 1 THEN
            -- nu avem ELSIF în MariaDB/MySQL
            -- putem avea ELSIF cu SET sql_mode=Oracle
            -- SET stdout = CONCAT(stdout, 'x chiar este ', x, '\n');
            INSERT INTO logs (msg) VALUES(CONCAT('x chiar este ', x));
        ELSE
            -- SET stdout = CONCAT(stdout, 'altceva', '\n');
            INSERT INTO logs (msg) VALUES('altceva');
        END IF;
        -- .
        -- https://mariadb.com/kb/en/case-statement/
        -- exemplu CASE
        CASE x
        WHEN 2 THEN 
                    INSERT INTO logs (msg) VALUES('2');
        WHEN 1 THEN INSERT INTO logs (msg) VALUES('1');
        ELSE        INSERT INTO logs (msg) VALUES('case 1 altceva');
        END CASE;
        -- .
        CASE
        WHEN x > 4 THEN          INSERT INTO logs (msg) VALUES('4');
        WHEN MOD(x, 3) <> 1 THEN INSERT INTO logs (msg) VALUES('3');
        ELSE                     INSERT INTO logs (msg) VALUES('case 2 altceva');
        END CASE;
        -- eroare: Result consisted of more than one row
        -- SELECT first_name
        -- INTO nume
        -- FROM employees;
        -- .
        SELECT first_name
        INTO nume
        FROM employees
        WHERE employee_id = 123;
        INSERT INTO logs (msg) VALUES(CONCAT('numele este ', nume));
        -- .
        -- dacă nu avem rezultate, variabila nu se modifică
        -- rămâne valoarea setată anterior
        SELECT first_name
        INTO nume
        FROM employees
        WHERE employee_id = 0;
        INSERT INTO logs (msg) VALUES(CONCAT('numele este ', nume));
        -- .
        SELECT *
        INTO ang
        FROM employees
        WHERE employee_id = 123;
        INSERT INTO logs(msg) VALUES (
            CONCAT('numele: ', ang.first_name,
            ', salariul: ', ang.salary)
        );
        -- .
        -- comenzile DDL merg în MariaDB
        CREATE TABLE IF NOT EXISTS tbl(id INT);
        SELECT COUNT(*)
        INTO j
        FROM tbl;
        INSERT INTO logs (msg) VALUES(CONCAT('j este ', j));
        DROP TABLE IF EXISTS tbl;
        -- .
        -- MySQL are doar LOOP, REPEAT/UNTIL și WHILE
        -- ITERATE echivalent cu CONTINUE
        -- LEAVE echivalent cu BREAK
        -- https://dev.mysql.com/doc/refman/8.1/en/loop.html
        -- .
        -- MariaDB >= 10.3 are în plus bucle FOR
        -- https://mariadb.com/kb/en/for/
        -- .
        -- incrementare/decrementare doar cu pas 1
        for1:
        FOR i IN 1..x DO
            IF i < 2 THEN ITERATE for1; END IF;
            IF i > 7 THEN LEAVE for1; END IF;
            INSERT INTO logs (msg) VALUES(CONCAT('for loop i: ', i, ' ', SYSDATE()));
        END FOR for1;
        -- .
        FOR i IN REVERSE 1..5 DO
            INSERT INTO logs (msg) VALUES(CONCAT('forr loop i: ', i));
        END FOR;
        -- .
        SET j = 0;
        loop2:
        LOOP
            SET j = j + 3;
            IF j > 8 THEN LEAVE loop2; END IF;
            INSERT INTO logs (msg) VALUES(CONCAT('loop j: ', j));
        END LOOP loop2;
        -- .
        WHILE j > 0 DO
            SET j = j - 2;
            INSERT INTO logs (msg) VALUES(CONCAT('while loop j: ', j));
        END WHILE;
        -- .
        REPEAT
            SET j = j + 4;
            INSERT INTO logs (msg) VALUES(CONCAT('repeat loop j: ', j));
        UNTIL j > 10 END REPEAT;
        -- SELECT stdout;
        SELECT * FROM logs;
    END;  </pre>
</details>


## Laborator 3 - colecții

#### Tipuri de date stocate

Unele baze de date ne permit definirea de noi tipuri de date, asemănător cu structurile din C.
Nu putem avea câmpuri cu `%TYPE` (sau `%ROWTYPE`). În Oracle, deși nu crapă la crearea tipului, primim erori ulterior.

Observăm că aceste tipuri de date pot fi folosite atât în SQL, cât și în limbaj procedural.

<details>
<summary>Oracle (documentație <a href="https://docs.oracle.com/en/database/oracle/oracle-database/23/lnpls/CREATE-TYPE-statement.html">aici</a>)</summary>
  <pre lang="sql">
    CREATE OR REPLACE TYPE tip_test AS OBJECT (
        id INT,
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
        FROM employees
        WHERE employee_id = 123;
        --
        -- dacă specificăm câmpurile explicit, variabila trebuie inițializată înainte
        SELECT employee_id, first_name
        INTO emp2.id, emp2.nume
        FROM employees
        WHERE employee_id = 123;
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
        FROM employees
        WHERE employee_id = 123;
        --
        SELECT employee_id, first_name
        INTO emp2.id, emp2.nume
        FROM employees
        WHERE employee_id = 123;
        --
        RAISE NOTICE '% %', emp1.id, emp1.nume;
        RAISE NOTICE '% %', emp2.id, emp2.nume;
    END $$;  </pre>
</details>


SQL Server nu are un echivalent pentru `CREATE TYPE` ca cele de mai sus ([sursa](https://learn.microsoft.com/en-us/sql/t-sql/statements/create-type-transact-sql)).
Pot fi create tipuri de date asociate cu clase din .NET.

În MyQL/MariaDB nu este implementat deloc `CREATE TYPE` ([sursa](https://stackoverflow.com/questions/10266101/create-type-on-mysql)).

SQLite nu permite crearea de noi tipuri de date.

Se poate emula cu `CREATE TABLE` (eventual temporar) sau cu JSON. JSON poate fi folosit în toate bazele de date relaționale relativ recente.

#### Tipuri de date locale

<details>
<summary>Oracle (documentație <a href="https://docs.oracle.com/en/database/oracle/oracle-database/23/lnpls/plsql-collections-and-records.html#GUID-75875E26-FC7B-4513-A5E2-EDA26F1D67B1">aici</a>)</summary>
  <pre lang="sql">
    DECLARE
        TYPE tip_ang is RECORD (
            nume    employees.first_name%TYPE,
            salariu employees.salary%TYPE
        );
        emp1 tip_ang;
    BEGIN
        SELECT first_name, salary
        INTO emp1
        FROM employees
        WHERE employee_id = 123;
        --
        DBMS_OUTPUT.PUT_LINE(emp1.nume || ' ' || emp1.salariu);
        --
        -- putem să specificăm câmpurile explicit
        SELECT first_name, salary
        INTO emp1.nume, emp1.salariu
        FROM employees
        WHERE employee_id = 123;
        --
        DBMS_OUTPUT.PUT_LINE(emp1.nume || ' ' || emp1.salariu);
    END;  </pre>
</details>


<details>
<summary>PostgreSQL (documentație <a href="https://www.postgresql.org/docs/current/plpgsql-declarations.html#PLPGSQL-DECLARATION-RECORDS">aici</a>)</summary>
  <pre lang="sql">
    DO $$
    DECLARE
        emp1 RECORD; -- nu are structură fixă
    BEGIN
        -- emp1 capătă structură de-abia când facem SELECT INTO variabilă
        SELECT first_name, salary
        INTO emp1
        FROM employees
        WHERE employee_id = 123;
        --
        RAISE NOTICE '% %', emp1.first_name, emp1.salary;
    END $$;  </pre>
</details>


Celelalte baze de date nu au un astfel de echivalent. Ar putea fi simulat cu JSON.

#### Tablouri indexate

Tablourile indexate există doar în PL/SQL (Oracle - [docs](https://docs.oracle.com/en/database/oracle/oracle-database/23/lnpls/plsql-collections-and-records.html#GUID-8060F01F-B53B-48D4-9239-7EA8461C2170)).
Indexarea se poate face cu pls_integer (aka binary_integer) sau cu șiruri de caractere (string, varchar, varchar2, long).
Tablourile indexate nu trebuie inițializare în prealabil. Nu pot fi folosite în SQL.

```sql
DECLARE
    TYPE tab_nr_idx IS TABLE OF NUMBER
        INDEX BY pls_integer;
    v_tab tab_nr_idx;
    i pls_integer;
BEGIN
    v_tab(2) := 55;
    v_tab(3) := 56;
    v_tab(360) := 1323;
    v_tab(-204) := 654;

    i := v_tab.FIRST;
    --WHILE i <> v_tab.LAST + 1 LOOP
    WHILE i IS NOT NULL LOOP
        DBMS_OUTPUT.PUT_LINE(
            i || ' ' || v_tab(i)
        );
        i := v_tab.NEXT(i);  -- de ce nu am incrementat?  i := i + 1;
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('i este ' || i || '.');
    IF v_tab.exists(100) THEN
        v_tab.delete(100);
    ELSE
        DBMS_OUTPUT.PUT_LINE('nu avem');
    END IF;
END;
```

#### Vectori de lungime fixă

Vectorii pot fi folosiți atât în SQL, cât și în limbaj procedural. Vectorii trebuie inițializați.

Oracle permite definirea unor vectori de lungime fixă:
```sql
CREATE OR REPLACE TYPE vec_numere IS varray(5) OF NUMBER;

SELECT vec_numere(1, 2, 6)
FROM dual;

DECLARE
    TYPE vec_nr IS VARRAY(10) OF NUMBER;
    v vec_nr := vec_nr(1, 2);
BEGIN
    DBMS_OUTPUT.PUT_LINE(
        'count: ' || v.count || ', ' ||
        'limit: ' || v.limit
    );
END;
```

În PostgreSQL, se poate crea ad-hoc un tip de date `ARRAY` de dimensiune variabilă pentru orice tip de date definit.
Dimensiunea nu trebuie specificată în prealabil ([sursa](https://www.postgresql.org/docs/current/arrays.html)).
```sql
DO $$
DECLARE
    -- arr INTEGER ARRAY[];   -- unidimensional
    -- arr INTEGER[][];       -- multidimensional array; nu se extind automat
    -- arr INTEGER ARRAY[10]; -- dacă specificăm o limită, este ignorată; ar putea fi util doar pt documentare
    arr INTEGER[];        -- nu este obligatoriu să specificăm o limită
BEGIN
    arr[1] = 2;  -- implicit indexare de la 1
    -- arr[-1] = 3;  -- pot fi folosiți indecși întregi arbitrari
    arr[2] = 4;
    -- arr[4] = 5;  -- pot exista goluri - acestea primesc valoarea NULL
    --
    RAISE NOTICE '%', arr;
END $$;
```

În SQL Server nu există arrays; în schimb, poate fi folosit `TABLE` (vezi mai jos).

MySQL/MariaDB nu implementează arrays. Pot fi emulați cu tabele temporare sau cu JSON.

SQLite are [extensii](https://github.com/nalgeon/sqlean/issues/27#issuecomment-1004109889) pentru vectori de lungime variabilă.

#### Tablouri imbricate

Tablourile imbricate par să existe doar în Oracle. Acestea pot fi folosite în SQL și în limbaj procedural.

În alte baze de date, ar putea fi emulate (parțial) cu tipuri de date tablou sau cu tabele temporare, însă avem nevoie și de cunoștințe despre
cursoare sau funcții.
O posibilă limitare la tabelele temporare este că trebuie să aibă nume distincte la nivel de sesiune.

<details>
<summary>Oracle (documentație <a href="https://docs.oracle.com/en/database/oracle/oracle-database/23/lnpls/plsql-collections-and-records.html#GUID-5ADB7EE2-71F6-4172-ACD8-FFDCF2787A37">aici</a>)</summary>
  <pre lang="sql">
    DECLARE
        TYPE tab_nr IS TABLE OF NUMBER;
        v tab_nr := tab_nr(3, 6, 0, 3, 6, 5);
        j NUMBER;
    BEGIN
        DBMS_OUTPUT.PUT_LINE(
            'count: ' || v.count || ', ' ||
            'limit: ' || v.limit
        );
        FOR i IN v.FIRST..v.LAST LOOP
            DBMS_OUTPUT.PUT_LINE('i: ' || i || ', ' ||
                'v(i): ' || v(i)
            );
        END LOOP;
    END;  </pre>
</details>


<details>
<summary>PostgreSQL (documentație <a href="https://www.postgresql.org/docs/current/sql-createtable.html">aici</a>)</summary>
  <pre lang="sql">
    DO $$
    DECLARE
        arr NUMERIC[];  -- dezavantaj: nu putem folosi %TYPE cu arrays
    BEGIN
        SELECT array_agg(salary)
        INTO arr
        FROM employees
        WHERE department_id = 30;
        RAISE NOTICE '%', arr;
        --
        -- cu tabele temporare
        CREATE TEMP TABLE tab_nr AS
        SELECT salary
        FROM employees
        WHERE department_id = 30;
        -- prelucrare rezultate din tab_nr prin cursoare/funcții
        -- https://stackoverflow.com/a/43832864
        DROP TABLE tab_nr;
    END $$;  </pre>
</details>


<details>
<summary>SQL Server (documentație <a href="https://learn.microsoft.com/en-us/sql/t-sql/statements/create-table-transact-sql#temporary-tables">aici</a> și <a href="https://learn.microsoft.com/en-us/sql/t-sql/data-types/table-transact-sql">aici</a>)</summary>
  <pre lang="sql">
    BEGIN
        -- https://learn.microsoft.com/en-us/sql/relational-databases/tables/use-table-valued-parameters-database-engine
        -- user-defined table types
        -- nu merge cu select ... into @my_tab
        DECLARE @my_tab TABLE (salar decimal);
        INSERT INTO @my_tab
        SELECT salary
        FROM employees
        WHERE department_id = 30;
        --
        -- prelucrare rezultate din @my_tab
        SELECT * FROM @my_tab; -- nu MERGE cu PRINT @my_tab;
        --
        -- temp tables: trebuie cu # ca să fie temporar
        CREATE TABLE #tab_nr(salary decimal);
        INSERT INTO #tab_nr
        SELECT salary
        FROM employees
        WHERE department_id = 30;
        --
        SELECT * FROM #tab_nr;
        -- prelucrare rezultate din #tab_nr
        DROP TABLE #tab_nr;
    END;  </pre>
</details>


<details>
<summary>MariaDB (documentație <a href="https://mariadb.com/kb/en/create-table/#create-temporary-table">aici</a>)</summary>
  <pre lang="sql">
    BEGIN NOT ATOMIC
        CREATE TEMPORARY TABLE tab_nr ENGINE=memory
            SELECT salary
            FROM employees
            WHERE department_id = 30;
        -- prelucrare rezultate din tab_nr
        SELECT * FROM tab_nr;
        DROP TABLE tab_nr;
    END;  </pre>
</details>


##### Tablou în tablou

Oracle:
```sql
CREATE OR REPLACE TYPE tab_int IS TABLE OF NUMBER;

CREATE OR REPLACE TYPE tab_tab IS TABLE OF tab_int;

CREATE TABLE tbl_imb (
    id int,
    tbl_int tab_int
)
NESTED TABLE tbl_int STORE AS tbl_int_store;

CREATE TABLE tbl_imb2 (
    id int,
    tbl_tab tab_tab
)
NESTED TABLE tbl_tab STORE AS tbl_tab_store;

SELECT tab_int(1, 2, 50)
FROM dual;
```

În PostgreSQL am folosi `ARRAY` (vezi mai sus).

În SQL Server nu putem avea coloane de tipuri de date tabel definite de noi ("A column cannot be of a user-defined table type").

MySQL/MariaDB și SQLite nu au astfel de coloane.

#### JSON

Docs: [Oracle](https://docs.oracle.com/en/database/oracle/oracle-database/23/lnpls/plsql-data-types.html#GUID-C2831EA4-CE44-475B-A4E7-2A6BDA5E82CC),
[PostgreSQL](https://www.postgresql.org/docs/current/datatype-json.html),
[SQL Server](https://learn.microsoft.com/en-us/sql/relational-databases/json/json-data-sql-server),
[MySQL](https://dev.mysql.com/doc/refman/8.1/en/json.html),
[MariaDB](https://mariadb.com/kb/en/json-data-type/),
[SQLite](https://www.sqlite.org/json1.html).

## Laborator 4 - colecții

TBA benchmarks. De văzut cu `t1 number := DBMS_UTILITY.GET_TIME;`.

## Laborator 5 - cursoare

De obicei este de preferat să lucrăm direct cu SELECT-uri pentru a procesa
mai multe rânduri deodată. Cursoarele procesează datele la nivel de un singur
rând. Doar în Oracle se pot prelucra mai multe rânduri deodată, dar și acolo
de obicei e mai rapid fără cursoare.

Un exemplu de situație când cursoarele ar putea fi utile este când avem de
actualizat o tabelă în care se fac foarte multe citiri: configurat corespunzător,
un cursor ar avea nevoie să blocheze doar câte un singur rând la un moment dat.

Alt exemplu de situație este dacă nu avem așa multe date și este mult mai ușor
de implementat procedural decât declarativ.

<details>
<summary>Oracle (documentație <a href="https://docs.oracle.com/en/database/oracle/oracle-database/23/lnpls/static-sql.html#GUID-89E0242F-42AC-4B21-9DF1-ACD6F4FC03B9">aici</a>)</summary>
  <pre lang="sql">
    DECLARE
        CURSOR crs(dep_id employees.department_id%TYPE) IS
            SELECT first_name AS nume,
                   hire_date AS zi
            FROM employees
            WHERE department_id = dep_id;
        --
        ang crs%ROWTYPE;
        --
        -- colecții
        --
        TYPE tab_idx IS TABLE OF crs%ROWTYPE
            INDEX BY PLS_INTEGER;
        tab tab_idx;
        j NUMBER := 0;
    BEGIN
        DBMS_OUTPUT.PUT_LINE('dep 20');
        OPEN crs(20);
        LOOP
            FETCH crs
            INTO ang;
            EXIT WHEN c%NOTFOUND;
            DBMS_OUTPUT.PUT_LINE(
                'nume: ' || ang.nume || ' ' ||
                'zi: ' || ang.zi
            );
        END LOOP;
        CLOSE crs;
        DBMS_OUTPUT.PUT_LINE('dep 40');
        --
        -- ciclu cursor
        FOR rec IN crs(40) LOOP
            DBMS_OUTPUT.PUT_LINE(
                'nume: ' || rec.nume || ' ' ||
                'zi: ' || rec.zi
            );
        END LOOP;
        --
        -- cu colecții
        DBMS_OUTPUT.PUT_LINE('dep 30');
        OPEN crs(dep_id => 30);
        LOOP
            -- parcurgem in batchuri si
            -- nu avem nevoie de order by
            FETCH crs
            BULK COLLECT INTO tab LIMIT 5;
            DBMS_OUTPUT.PUT_LINE(
                'nr total: ' || crs%ROWCOUNT
            );
            -- NOTFOUND dacă nu am luat cât am cerut în clauza LIMIT
            -- EXIT WHEN crs%NOTFOUND;
            EXIT WHEN j = crs%ROWCOUNT;
            --
            FOR i IN tab.FIRST..tab.LAST LOOP
                j := j + 1;
                DBMS_OUTPUT.PUT_LINE(
                    'j: ' || j || ', ' ||
                    tab(i).nume || ', ' ||
                    tab(i).zi
                );
            END LOOP;
        END LOOP;
        CLOSE crs;
    END;  </pre>
</details>

<details>
<summary>Exemplu SQL injection</summary>
  <pre lang="sql">
    DECLARE
        c_ref SYS_REFCURSOR;
        -- query varchar2(30) := ' ''T'' ';
        query varchar2(30) := ' ''T'' or 1=1';
        --query varchar2(30) := 'T';
        fn employees.first_name%TYPE;
        zi employees.hire_date%TYPE;
    BEGIN
        OPEN c_ref FOR
            'select first_name, hire_date ' ||
            'from employees ' ||
            'where first_name < :query'
            USING query;
        -- am avea SQL injection dacă am concatena direct variabila query
        --
        LOOP
            FETCH c_ref
            INTO fn, zi;
            EXIT WHEN c_ref%NOTFOUND;
            DBMS_OUTPUT.PUT_LINE(fn || ' ' || zi);
        END LOOP;
        --
        CLOSE c_ref;
    END;  </pre>
</details>

<details>
<summary>Exemplu DDL în Oracle (documentație <a href="https://docs.oracle.com/en/database/oracle/oracle-database/23/arpls/DBMS_SQL.html">aici</a>)</summary>
  <pre lang="sql">
    DECLARE
        cursor_name INTEGER;
        ignore INTEGER;
        nr INTEGER;
        crs SYS_REFCURSOR;
    BEGIN
        cursor_name := DBMS_SQL.OPEN_CURSOR;
        DBMS_SQL.PARSE(cursor_name, 'CREATE TABLE tbl(id INT)', DBMS_SQL.NATIVE);
        ignore := DBMS_SQL.EXECUTE(cursor_name);
        -- eroare, tbl nu există
        -- SELECT COUNT(*)
        -- INTO nr
        -- FROM tbl;
        DBMS_SQL.PARSE(cursor_name, 'SELECT COUNT(*) FROM tbl', DBMS_SQL.NATIVE);
        ignore := DBMS_SQL.EXECUTE(cursor_name);
        --
        -- Switch from DBMS_SQL to native dynamic SQL
        crs := DBMS_SQL.TO_REFCURSOR(cursor_name);
        FETCH crs INTO nr;
        CLOSE crs;
        DBMS_OUTPUT.PUT_LINE('nr este ' || nr);
        -- https://stackoverflow.com/questions/57867587
        --
        cursor_name := DBMS_SQL.OPEN_CURSOR;
        DBMS_SQL.PARSE(cursor_name, 'DROP TABLE tbl', DBMS_SQL.NATIVE);
        ignore := DBMS_SQL.EXECUTE(cursor_name);
        DBMS_SQL.CLOSE_CURSOR(cursor_name);
    EXCEPTION
        WHEN OTHERS THEN
            -- cârpeală necesară înainte de 23c
            -- în 23c avem CREATE TABLE IF NOT EXISTS
            -- 955 există deja; 942 nu există
            IF SQLCODE = -955 OR SQLCODE = -942 THEN
                DBMS_OUTPUT.PUT_LINE('nop');
                NULL;
            ELSE
                RAISE;
            END IF;
    END;  </pre>
</details>


<details>
<summary>PostgreSQL (documentație <a href="https://www.postgresql.org/docs/current/plpgsql-cursors.html">aici</a>)</summary>
  <pre lang="sql">
    DO $$
    DECLARE
        crs CURSOR (dep_id employees.department_id%TYPE) FOR
            SELECT first_name AS nume,
                   hire_date AS zi
            FROM employees
            WHERE department_id = dep_id;
        ang RECORD;
    BEGIN
        RAISE NOTICE 'dep 40';
        OPEN crs(40);
        LOOP
            FETCH crs
            INTO ang;
            EXIT WHEN NOT FOUND;
            RAISE NOTICE '%', ang;  -- putem afișa un record cu totul
        END LOOP;
        CLOSE crs;
        --
        RAISE NOTICE 'dep 30';
        FOR rec IN crs(dep_id := 30) LOOP
            RAISE NOTICE 'nume: %, zi: %', rec.nume, rec.zi;
        END LOOP;
        -- cursoarele din Postgres pot fi scrollable (dacă datele nu se schimbă)
        -- se închid automat la încheierea tranzacției
        -- nu putem face fetch la mai multe rânduri deodată
        -- folosim MOVE în loc de FETCH dacă nu avem nevoie de date
        --
        -- Postgres are și cursoare la nivel de SQL
        -- https://www.postgresql.org/docs/current/sql-declare.html
    END $$;  </pre>
</details>


<details>
<summary>SQL Server (documentație <a href="https://learn.microsoft.com/en-us/sql/t-sql/language-elements/cursors-transact-sql">aici</a>)</summary>
  <pre lang="sql">
    BEGIN
        DECLARE @nume VARCHAR(30);
        DECLARE @zi DATE;
        DECLARE Employee_Cursor CURSOR FOR
            SELECT first_name AS nume,
                   hire_date AS zi
            FROM employees
            WHERE department_id = 20; -- nu avem cursoare cu parametru în T-SQL
        --
        OPEN Employee_Cursor;
        FETCH NEXT FROM Employee_Cursor
        INTO @nume, @zi;
        --
        WHILE @@FETCH_STATUS = 0
            BEGIN
                PRINT @nume + ', ' + CAST(@zi AS VARCHAR);
                FETCH NEXT FROM Employee_Cursor
                INTO @nume, @zi;
            END;
        CLOSE Employee_Cursor;
        DEALLOCATE Employee_Cursor;
    END;  </pre>
</details>


<details>
<summary>MariaDB (documentație <a href="https://mariadb.com/kb/en/cursor-overview/">aici</a>)</summary>
  <pre lang="sql">
    SET sql_mode='';
    BEGIN NOT ATOMIC
        DECLARE done INT DEFAULT FALSE;
        DECLARE nume VARCHAR(30);
        DECLARE zi date;
        DECLARE crs CURSOR (dep_id INT) FOR
                    SELECT first_name AS nume,
                           hire_date AS zi
                    FROM employees
                    WHERE department_id = dep_id;
        DECLARE CONTINUE HANDLER FOR NOT FOUND SET done=TRUE;
        SELECT 'dep 20';
        OPEN crs(20);
        read_loop: LOOP
            FETCH crs
            INTO nume, zi;
            IF done THEN
                LEAVE read_loop;
            END IF;
            SELECT nume, zi;
        END LOOP;
        CLOSE crs;
        -- .
        SELECT 'dep 30';
        FOR rec IN crs(30) DO
            SELECT rec.nume, rec.zi;
        END FOR;
    END;  </pre>
</details>

<details>
<summary>MariaDB în mod Oracle (documentație <a href="https://mariadb.com/kb/en/sql_modeoracle/">aici</a>)</summary>
  <pre lang="sql">
    SET sql_mode=Oracle;
    DECLARE
        nume VARCHAR(30);
        zi date;
        CURSOR crs (dep_id employees.department_id%TYPE) IS
                    SELECT first_name AS nume,
                           hire_date AS zi
                    FROM employees
                    WHERE department_id = dep_id;
    BEGIN
        SELECT 'dep 20';
        OPEN crs(20);
        LOOP
            FETCH crs
            INTO nume, zi;
            EXIT WHEN crs%NOTFOUND;
            SELECT nume, zi;
        END LOOP;
        CLOSE crs;
        -- .
        SELECT 'dep 30';
        FOR rec IN crs(30) LOOP
            SELECT rec.nume, rec.zi;
        END LOOP;
    END;  </pre>
</details>


Nu există cursoare în SQLite.

Putem parcurge pe bucăți seturi mari de date direct din SQL în toate bazele de date fără să avem nevoie de cursoare:
```sql
SELECT coloana1, coloana2
FROM tabel1
WHERE conditie AND col_idx < valoare
ORDER BY col_idx
FETCH FIRST n ROWS ONLY; -- standard SQL
--
-- SELECT TOP n ... -- în SQL Server
--
-- ORDER BY ... LIMIT n OFFSET k -- în Postgres/MySQL/MariaDB/SQLite
```

Ideea este să avem index pe coloana `col_idx`: astfel, se sortează doar datele din index și apoi este necesar
să accesăm numai aceste rânduri, mult mai puține decât dacă ar fi trebuit să ordonăm/accesăm toate datele.
Fie punem clauză de limită de rânduri, fie punem în condiția `WHERE` ca valoarea lui `col_idx` să fie între 2 valori apropiate.

## Laborator 6 - cursoare

## Laborator 7 - funcții și proceduri

O funcție trebuie să întoarcă întotdeauna un rezultat. Funcțiile pot fi folosite
direct din SQL. Procedurile nu întorc un rezultat, dar pot avea parametri de
ieșire. Procedurile nu pot fi apelate întotdeauna ușor din SQL.

Pe lângă tipurile de date uzuale, funcțiile pot întoarce cursoare și tabele.

Nu există funcții sau proceduri în SQLite. Funcțiile ar putea fi simulate cu extensia [define](https://github.com/nalgeon/sqlean/blob/main/docs/define.md).

Refolosim exemplul de la cursoare. Vom implementa subprograme care parcurg
un cursor și afișează datele din setul de date. În cazul funcțiilor, vom
întoarce numărul de rânduri procesate.


<details>
<summary>Funcții Oracle (documentație <a href="https://docs.oracle.com/en/database/oracle/oracle-database/23/lnpls/plsql-subprograms.html">aici</a>)</summary>
  <pre lang="sql">
    CREATE OR REPLACE FUNCTION func_afis_dep(dep_id employees.department_id%TYPE)
    RETURNS NUMBER  -- sau RETURN, dar RETURNS e mai portabil
    IS
        nr NUMBER := 0;
        CURSOR crs(dep_id employees.department_id%TYPE) IS
            SELECT first_name AS nume,
                   hire_date AS zi
            FROM employees
            WHERE department_id = dep_id;
    BEGIN
        -- în exemplul de la cursoare am repetat logica de afișare
        FOR rec IN crs(dep_id) LOOP
            DBMS_OUTPUT.PUT_LINE(
                'nume: ' || rec.nume || ' ' ||
                'zi: ' || rec.zi
            );
            nr := nr + 1;
        END LOOP;
        RETURN nr;
    END func_afis_dep;
    --
    -- apel din SQL
    SELECT func_afis_dep(20)
    FROM dual;
    --
    -- apel din PL/SQL
    BEGIN
        DBMS_OUTPUT.PUT_LINE(func_afis_dep(20));
        DBMS_OUTPUT.PUT_LINE(func_afis_dep(30));
    END;  </pre>
</details>

<details>
<summary>Proceduri Oracle</summary>
  <pre lang="sql">
    CREATE OR REPLACE PROCEDURE proc_afis_dep(
        dep_id IN employees.department_id%TYPE,
        nr OUT NUMBER
    )
    IS
        CURSOR crs(dep_id employees.department_id%TYPE) IS
            SELECT first_name AS nume,
                   hire_date AS zi
            FROM employees
            WHERE department_id = dep_id;
    BEGIN
        nr := 0;
        FOR rec IN crs(dep_id) LOOP
            DBMS_OUTPUT.PUT_LINE(
                'nume: ' || rec.nume || ' ' ||
                'zi: ' || rec.zi
            );
            nr := nr + 1;
        END LOOP;
    END proc_afis_dep;
    --
    -- apel din PL/SQL
    --
    DECLARE
        nr NUMBER;
    BEGIN
        proc_afis_dep(10, nr);
        DBMS_OUTPUT.PUT_LINE('nr este ' || nr);
        proc_afis_dep(20, nr);
        DBMS_OUTPUT.PUT_LINE('nr este ' || nr);
    END;  </pre>
</details>


<details>
<summary>Funcții PostgreSQL (documentație <a href="https://www.postgresql.org/docs/current/sql-createfunction.html">aici</a>)</summary>
  <pre lang="sql">
    CREATE OR REPLACE FUNCTION func_afis_dep(dep_id employees.department_id%TYPE)
    RETURNS INTEGER
    AS $$
    DECLARE
        nr INTEGER = 0;
        crs CURSOR(dep_id employees.department_id%TYPE) IS
            SELECT first_name AS nume,
                   hire_date AS zi
            FROM employees
            WHERE department_id = dep_id;
    BEGIN
        FOR rec IN crs(dep_id) LOOP
            RAISE NOTICE 'nume: %, zi: %', rec.nume, rec.zi;
            nr = nr + 1;
        END LOOP;
        RETURN nr;
    END;
    $$ LANGUAGE plpgsql;
    --
    -- apel din SQL
    SELECT func_afis_dep(20);
    --
    -- apel din PL/pgSQL
    DO $$
    BEGIN
        RAISE NOTICE 'dep 20: %', func_afis_dep(20);
        RAISE NOTICE 'dep 30: %', func_afis_dep(30);
    END $$;  </pre>
</details>

<details>
<summary>Proceduri PostgreSQL (documentație <a href="https://www.postgresql.org/docs/current/sql-createprocedure.html">aici</a>)</summary>
  <pre lang="sql">
    CREATE OR REPLACE PROCEDURE proc_afis_dep(
        IN dep_id employees.department_id%TYPE,
        OUT nr INTEGER
    )
    LANGUAGE plpgsql -- putem avea proceduri și cu LANGUAGE SQL
    AS $$
    DECLARE
        crs CURSOR(dep_id employees.department_id%TYPE) IS
            SELECT first_name AS nume,
                   hire_date AS zi
            FROM employees
            WHERE department_id = dep_id;
    BEGIN
        nr = 0;
        FOR rec IN crs(dep_id) LOOP
            RAISE NOTICE 'nume: %, zi: %', rec.nume, rec.zi;
            nr = nr + 1;
        END LOOP;
    END;
    $$
    --
    -- apel din SQL
    CALL proc_afis_dep(20, NULL);
    --
    -- apel din PL/pgSQL
    DO $$
    DECLARE
        nr INTEGER;
    BEGIN
        CALL proc_afis_dep(10, nr);
        RAISE NOTICE 'nr este %', nr;
        CALL proc_afis_dep(20, nr);
        RAISE NOTICE 'nr este %', nr;
    END $$;  </pre>
</details>


<details>
<summary>Funcții SQL Server (documentație <a href="https://learn.microsoft.com/en-us/sql/t-sql/statements/create-function-transact-sql">aici</a>)</summary>
  <pre lang="sql">
    CREATE OR ALTER FUNCTION dbo.func_afis_dep(@dep_id INT) -- trebuie () și dacă nu avem params
    RETURNS INT
    AS
    BEGIN
        DECLARE @nume VARCHAR(30);
        DECLARE @zi DATE;
        DECLARE @nr INT;
        DECLARE Employee_Cursor CURSOR FOR
            SELECT first_name AS nume,
                   hire_date AS zi
            FROM employees
            WHERE department_id = @dep_id;
        --
        SET @nr = 0;
        OPEN Employee_Cursor;
        FETCH NEXT FROM Employee_Cursor
        INTO @nume, @zi;
        --
        WHILE @@FETCH_STATUS = 0
            BEGIN
                -- nu avem voie cu PRINT în funcții din SQL Server
                -- PRINT @nume + ', ' + CAST(@zi AS VARCHAR);
                SET @nr = @nr + 1;
                FETCH NEXT FROM Employee_Cursor
                INTO @nume, @zi;
            END;
        CLOSE Employee_Cursor;
        DEALLOCATE Employee_Cursor;
        RETURN @nr;
    END;
    --
    COMMIT;
    --
    -- apel din SQL
    SELECT dbo.func_afis_dep(20);
    --
    -- apel din T-SQL
    BEGIN
        DECLARE @nr INT;
        SET @nr = dbo.func_afis_dep(30);
        SELECT @nr;
        SET @nr = (SELECT dbo.func_afis_dep(60));
        SELECT @nr;
    END;  </pre>
</details>

<details>
<summary>Proceduri SQL Server (documentație <a href="https://learn.microsoft.com/en-us/sql/t-sql/statements/create-procedure-transact-sql">aici</a>)</summary>
  <pre lang="sql">
    CREATE OR ALTER PROCEDURE dbo.proc_afis_dep(@dep_id INT, @nr INT OUT)
    AS
    BEGIN
        DECLARE @nume VARCHAR(30);
        DECLARE @zi DATE;
        DECLARE Employee_Cursor CURSOR FOR
            SELECT first_name AS nume,
                   hire_date AS zi
            FROM employees
            WHERE department_id = @dep_id;
        --
        SET @nr = 0;
        OPEN Employee_Cursor;
        FETCH NEXT FROM Employee_Cursor
        INTO @nume, @zi;
        --
        WHILE @@FETCH_STATUS = 0
            BEGIN
                PRINT @nume + ', ' + CAST(@zi AS VARCHAR);
                SET @nr = @nr + 1;
                FETCH NEXT FROM Employee_Cursor
                INTO @nume, @zi;
            END;
        CLOSE Employee_Cursor;
        DEALLOCATE Employee_Cursor;
    END;
    --
    COMMIT;
    --
    -- apel
    BEGIN
        DECLARE @nr INT;
        EXECUTE dbo.proc_afis_dep @dep_id = 20, @nr = @nr OUT;
        PRINT 'nr este ' + LTRIM(STR(@nr));
        EXECUTE dbo.proc_afis_dep @dep_id = 30, @nr = @nr OUT;
        PRINT 'nr este ' + LTRIM(STR(@nr));
    END;  </pre>
</details>


<details>
<summary>Funcții MariaDB (documentație <a href="https://mariadb.com/kb/en/stored-functions/">aici</a>)</summary>
  <pre lang="sql">
    -- setup inițial
    CREATE TABLE IF NOT EXISTS logs (
            ts TIMESTAMP DEFAULT current_timestamp,
            msg VARCHAR(2048)
        ) ENGINE = myisam;
    TRUNCATE TABLE logs;
    -- .
    SET sql_mode='';
    CREATE OR REPLACE FUNCTION func_afis_dep(dep_id INT)
    RETURNS INT
    BEGIN
        DECLARE nr INT;
        DECLARE crs CURSOR(dep_id INT) FOR
            SELECT first_name AS nume,
                   hire_date AS zi
            FROM employees
            WHERE department_id = dep_id;
        SET nr = 0;
        FOR rec IN crs(dep_id) DO
            INSERT INTO logs(msg) VALUES(CONCAT(rec.nume, ' ', rec.zi));
            SET nr = nr + 1;
        END FOR;
        RETURN nr;
    END;
    -- .
    -- apel din cod procedural
    BEGIN NOT ATOMIC
        DECLARE res TEXT;
        TRUNCATE TABLE logs;
        SET res = func_afis_dep(30);
        -- nu merge direct INSERT INTO logs(msg) VALUES(func_afis_dep(30));
        -- avem nevoie de variabilă deoarece apelul de funcție
        -- face de asemenea un insert în tabela logs
        INSERT INTO logs(msg) VALUES(res);
        SELECT * FROM logs;
    END;  </pre>
</details>

<details>
<summary>Funcții MariaDB în mod Oracle</summary>
<pre lang="sql">
    SET sql_mode=Oracle;
    CREATE OR REPLACE FUNCTION func_afis_dep(dep_id employees.department_id%TYPE)
    RETURN INT -- nu merge cu RETURNS
    AS
        nr INT := 0;
        CURSOR crs(dep_id employees.department_id%TYPE) IS
            SELECT first_name AS nume,
                   hire_date AS zi
            FROM employees
            WHERE department_id = dep_id;
    BEGIN
        FOR rec IN crs(dep_id) LOOP
            INSERT INTO logs(msg) VALUES(CONCAT(rec.nume, ' ', rec.zi));
            nr := nr + 1;
        END LOOP;
        RETURN nr;
    END;
    -- .
    -- apel din SQL
    TRUNCATE TABLE logs;
    SELECT func_afis_dep(20);
    SELECT * FROM logs;
    -- .
    TRUNCATE TABLE logs;
    SELECT func_afis_dep(30);
    SELECT * FROM logs;  </pre>
</details>

<details>
<summary>Proceduri MariaDB (documentație <a href="https://mariadb.com/kb/en/stored-procedures/">aici</a>)</summary>
  <pre lang="sql">
    SET sql_mode='';
    CREATE OR REPLACE PROCEDURE proc_afis_dep(IN dep_id INT, OUT nr INT)
    BEGIN
        DECLARE crs CURSOR(dep_id INT) FOR
            SELECT first_name AS nume,
                   hire_date AS zi
            FROM employees
            WHERE department_id = dep_id;
        SET nr = 0;
        TRUNCATE TABLE logs; -- procedurile pot conține COMMIT-uri
        FOR rec IN crs(dep_id) DO
            INSERT INTO logs(msg) VALUES(CONCAT(rec.nume, ' ', rec.zi));
            SET nr = nr + 1;
        END FOR;
    END;
    -- .
    -- apel din limbaj procedural
    BEGIN NOT ATOMIC
        DECLARE nr INT;
        CALL proc_afis_dep(30, nr);
        SELECT * FROM logs;
        SELECT nr;
    END;  </pre>
</details>


#### Pachete

Avem pachete (asemănătoare cu spațiile de nume din C++ și C#) în [Oracle](https://docs.oracle.com/en/database/oracle/oracle-database/23/lnpls/CREATE-PACKAGE-statement.html) (alte [docs](https://docs.oracle.com/en/database/oracle/oracle-database/23/lnpls/plsql-packages.html))
și [MariaDB](https://mariadb.com/kb/en/create-package/) (dar nu și MySQL).
În [PostgreSQL](https://www.postgresql.org/docs/current/sql-createschema.html) și
[SQL Server](https://learn.microsoft.com/en-us/sql/t-sql/statements/create-schema-transact-sql)
(vezi și [aici](https://stackoverflow.com/questions/27833885/create-packages-in-sql-server-management-studio-without-ssis)),
pachetele pot fi emulate cu ajutorul schemelor.

Nu există pachete în SQLite, iar schemele înseamnă pur și simplu [fișiere separate](https://www.sqlite.org/lang_attach.html) (`.db`, `.sqlite` sau similar).

## Laborator 8 - declanșatori

Declanșatorii se pot clasifica în mai multe feluri:
- categorie: de sistem și de aplicație
- momentul declanșării: BEFORE, AFTER, INSTEAD OF
- de câte ori se declanșează: la nivel de cerere (instrucțiune) și la nivel de rând

Folosim triggeri de tip BEFORE dacă vrem să facem validări mai complexe. Exemple:
- unicitate pe date din mai multe tabele
- simulat chei străine
- constrângeri dificil de exprimat cu CHECK constraints

Folosim triggeri de tip AFTER în următoarele situații:
- loguri și auditări
- denormalizarea bazei de date pentru acces mai rapid la date

Este de preferat să avem triggeri separați decât să avem un singur trigger cu
verificări la runtime pentru tipul de eveniment din motive de performanță.

În Oracle, nu ne putem referi la rândurile modificate în triggeri la nivel de instrucțiune.

În Postgres și SQL Server nu avem această restricție:
- pentru Postgres, avem clauza `REFERENCING OLD/NEW TABLE AS...`
- pentru SQL Server, avem tabelele `INSERTED` și `DELETED`

<details>
<summary>Oracle (documentație <a href="https://docs.oracle.com/en/database/oracle/oracle-database/23/lnpls/plsql-triggers.html">aici</a>)</summary>
  <pre lang="sql">
    -- setup inițial
    CREATE TABLE employees_copy AS SELECT * FROM employees;
    --
    CREATE OR REPLACE TRIGGER trig_ang
    BEFORE
    UPDATE OF first_name
    ON employees_copy
    FOR EACH ROW
    DECLARE
	    nr INT;
    BEGIN
	    SELECT COUNT(*)
	    INTO nr
	    -- FROM employees_copy e  -- nu merge așa - trigger is mutating
	    -- problema cu mutating e doar pe Oracle
	    -- se poate rezolva cu compound trigger
	    FROM employees e
	    WHERE e.DEPARTMENT_ID = :OLD.department_id;
        --
	    IF nr > 20 THEN
		    RAISE_APPLICATION_ERROR(-20001, 'prea multa lume');
	    END IF;
    END trig_ang;
    --
    -- teste trigger
    --
    -- update care declanșează trigger-ul
    UPDATE employees_copy
    SET first_name = 'asd'
    WHERE employee_id = 179;
    --
    -- update care nu declanșează trigger-ul
    UPDATE employees_copy
    SET first_name = 'asd'
    WHERE employee_id = 178;
    --
    ROLLBACK;
    --
    -- cleanup
    -- automat se face DROP și la trigger
    DROP TABLE employees_copy;  </pre>
</details>

<details>
<summary>PostgreSQL (documentație <a href="https://www.postgresql.org/docs/current/sql-createtrigger.html">aici</a> și <a href="https://www.postgresql.org/docs/current/plpgsql-trigger.html">aici</a>)</summary>
  <pre lang="sql">
    -- setup inițial
    CREATE TABLE employees_copy AS SELECT * FROM employees;
    COMMIT;
    --
    CREATE OR REPLACE FUNCTION trig_ang()
    RETURNS TRIGGER AS $trig_ang$
    DECLARE
        nr INT;
    BEGIN
        SELECT COUNT(*)
        INTO nr
        FROM employees_copy e
        WHERE e.DEPARTMENT_ID = OLD.department_id;
        --
        IF nr > 20 THEN
            RAISE EXCEPTION 'prea multa lume';
        END IF;
        RETURN NEW;
    END;
    $trig_ang$ LANGUAGE plpgsql;
    --
    CREATE OR REPLACE TRIGGER trig_ang
    BEFORE
    UPDATE OF first_name
    ON employees_copy
    FOR EACH ROW
    EXECUTE FUNCTION trig_ang();
    --
    -- teste trigger
    --
    -- update care declanșează trigger-ul
    UPDATE employees_copy
    SET first_name = 'asd'
    WHERE employee_id = 179;
    --
    -- update care nu declanșează trigger-ul
    UPDATE employees_copy
    SET first_name = 'asd'
    WHERE employee_id = 178;
    --
    ROLLBACK;
    --
    -- cleanup
    -- automat se face DROP și la trigger
    DROP TABLE employees_copy;  </pre>
</details>

<details>
<summary>SQL Server (documentație <a href="https://learn.microsoft.com/en-us/sql/t-sql/statements/create-trigger-transact-sql">aici</a>)</summary>
  <pre lang="sql">
    -- setup inițial
    SELECT * INTO dbo.employees_copy FROM dbo.employees;
    --
    CREATE OR ALTER TRIGGER dbo.trig_ang
    ON dbo.employees_copy
    AFTER   -- nu există triggeri before sau la nivel de linie
    UPDATE  -- nu putem specifica o coloană
    AS
    IF (ROWCOUNT_BIG() = 0)
    RETURN;  -- pt că mare parte din logică poate fi înainte de BEGIN
    IF EXISTS (
        SELECT COUNT(*)
        FROM dbo.employees_copy e
        WHERE e.department_id IN (SELECT department_id FROM inserted)
        GROUP BY e.department_id
        HAVING count(*) > 20
    )
    BEGIN
        -- argumentul 2
        --   de la 11 la 19 pt severitate
        --   sub 11 nu se afișează mesajul nostru
        -- argumentul 3: 0-255
        --   punctul unde are loc eroarea
        --   ar trebui să fie unic (la nivel de program)
        RAISERROR('prea multa lume', 11, 0);
        ROLLBACK TRANSACTION;
        RETURN;
    END;
    --
    COMMIT TRANSACTION;
    --
    -- update care declanșează trigger-ul
    UPDATE dbo.employees_copy
    SET first_name = 'asd'
    WHERE employee_id = 179;
    --
    -- update care nu declanșează trigger-ul
    UPDATE dbo.employees_copy
    SET first_name = 'asd'
    WHERE employee_id = 178;
    --
    -- cleanup
    -- automat se face DROP și la trigger
    DROP TABLE dbo.employees_copy;  </pre>
</details>

<details>
<summary>MariaDB (documentație <a href="https://mariadb.com/kb/en/create-trigger/">aici</a>)</summary>
  <pre lang="sql">
    -- setup inițial
    CREATE TABLE employees_copy AS SELECT * FROM employees;
    --
    CREATE OR REPLACE TRIGGER trig_ang
    BEFORE  -- sau AFTER
    UPDATE  -- nu putem limita coloanele afectate
    ON employees_copy
    FOR EACH ROW -- trigger doar la nivel de rând
    BEGIN
        DECLARE nr INT;
        SET nr = 0;
        SELECT COUNT(*)
        INTO nr
        FROM employees_copy e
        WHERE e.DEPARTMENT_ID = OLD.department_id;
        --
        IF nr > 20 THEN
            -- https://mariadb.com/kb/en/sqlstate/
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'prea multa lume';
        END IF;
    END;
    --
    -- update care declanșează trigger-ul
    UPDATE employees_copy
    SET first_name = 'asd'
    WHERE employee_id = 179;
    --
    -- update care nu declanșează trigger-ul
    UPDATE employees_copy
    SET first_name = 'asd'
    WHERE employee_id = 178;
    --
    -- cleanup
    -- automat se face DROP și la trigger
    DROP TABLE employees_copy;  </pre>
</details>

<details>
<summary>SQLite (documentație <a href="https://www.sqlite.org/lang_createtrigger.html">aici</a>)</summary>
  <pre lang="sql">
    -- setup inițial
    CREATE TABLE employees_copy AS SELECT * FROM employees;
    --
    CREATE TRIGGER trig_ang
    BEFORE  -- dar sunt de preferat AFTER triggers
    UPDATE OF first_name
    ON employees_copy
    FOR EACH ROW -- trigger doar la nivel de rând
    WHEN (
        SELECT COUNT(*)
        FROM employees_copy e
        WHERE e.DEPARTMENT_ID = OLD.department_id
    ) > 20
    BEGIN
        -- https://stackoverflow.com/questions/22201049/
        SELECT RAISE(ROLLBACK,'prea multa lume');
    END;
    --
    -- update care declanșează trigger-ul
    UPDATE employees_copy
    SET first_name = 'asd'
    WHERE employee_id = 179;
    --
    -- update care nu declanșează trigger-ul
    UPDATE employees_copy
    SET first_name = 'asd'
    WHERE employee_id = 178;
    --
    -- cleanup
    -- automat se face DROP și la trigger
    DROP TABLE employees_copy;  </pre>
</details>


## Laborator 9 - declanșatori
