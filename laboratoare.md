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
  Nu îmi este clar din documentație dacă se poate mai ok altfel.
</details>

#### Exemplu mai elaborat

<details>
<summary>Oracle</summary>
  <pre lang="sql">
    DECLARE
        x int := NULL;
    BEGIN
        SELECT COUNT(*)
        INTO x
        FROM EMPLOYEES e;
        --WHERE 1 = 0;
        --CREATE TABLE tbl(id int);
        --DROP TABLE tbl;
        DBMS_OUTPUT.PUT_LINE('Hello, world!');
        IF x > 0 THEN
           DBMS_OUTPUT.PUT_LINE('x este ' || x);
        END IF;
        FOR i IN 1..x LOOP
            CONTINUE WHEN i < 2;
            EXIT WHEN i > 3;
            DBMS_OUTPUT.PUT_LINE(i);
        END LOOP;
    END;  </pre>
</details>

<details>
<summary>PostgreSQL</summary>
  <pre lang="sql">
    DO $$
    DECLARE
        x int = 2;
    BEGIN
        SELECT COUNT(*)
        INTO x
        FROM EMPLOYEES e;
        --WHERE 1 = 0;
        RAISE NOTICE 'Hello, world!';
        IF x > 0 THEN
            RAISE NOTICE 'x este %', x;
        END IF;
        CREATE TABLE tbl(id int);
        DROP TABLE tbl;
        FOR i IN 1..x BY 2 LOOP
            CONTINUE WHEN i < 2;
            EXIT WHEN i > 8;
            RAISE NOTICE '%, %', i, now();
        END LOOP;
    END $$; </pre>
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


## Laborator 3 - colecții

Tabelele imbricate pot fi emulate cu tabele temporare.

## Laborator 4 - colecții
## Laborator 5 - cursoare
## Laborator 6 - cursoare
## Laborator 7 - funcții și proceduri
## Laborator 8 - declanșatori
## Laborator 9 - declanșatori
