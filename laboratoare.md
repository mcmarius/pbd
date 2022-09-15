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
## Laborator 3 - colecții
## Laborator 4 - colecții
## Laborator 5 - cursoare
## Laborator 6 - cursoare
## Laborator 7 - funcții și proceduri
## Laborator 8 - declanșatori
## Laborator 9 - declanșatori
