# Sisteme Avansate de Baze de Date

### Introducere

Termenul de "bază de date" (BD sau DB) se poate referi la:
- bază de date la nivel de SQL: `CREATE DATABASE test_db;`
- sistem de gestiune a bazelor de date (SGBD/DBMS)

SGBD-urile relaționale cele mai întâlnite sunt Oracle, MySQL/MariaDB, Microsoft SQL Server, PostgreSQL și SQLite.
Ar mai fi și [altele](https://db-engines.com/en/ranking/relational+dbms),
dar nu prea sunt alese în practică pentru proiecte noi, motiv pentru care nu le consider de interes.

În majoritatea situațiilor de mai jos, prin bază de date ne referim de fapt la SGBD.

Pentru a ne conecta la o bază de date, avem nevoie de un client SQL.
Unele astfel de utilitare au mai multe instrumente pe lângă client, însă nu au și serverul de baze de date.

Exemple de client GUI: Oracle SQL Developer, DataGrip, DBeaver, PgAdmin, SQL Workbench, SSMS.

Exemple de client din linie de comandă: sqlplus, psql.

Avem mai multe motive să ne creăm o bază de date locală pe lângă baza de date de la facultate:
- drepturi de admin ca să înțelegem mai bine ce se întâmplă
- acces la versiuni mai noi
- loc de experimentat fără să fie vreo problemă dacă stricăm ceva esențial
- soluție de backup dacă nu merge BD a facultății

### Cerințe preliminare pentru serverele de baze de date
- minim 8-10 GB spațiu liber pe disc
  - avem nevoie de spațiu atât pentru SGBD-uri, cât și pentru programele ajutătoare
  - bazele de date create de noi nu ar trebui să ocupe mai mult de câțiva MB
- instalare [`docker`](https://docs.docker.com/engine/install/) sau [`podman`](https://podman.io/getting-started/installation)

Spațiul ocupat de imagini (total ~4.2 GB):
```
$ podman images
REPOSITORY                      TAG          IMAGE ID      CREATED       SIZE
docker.io/library/mariadb       10.9         01d138caf7d0  2 weeks ago   391 MB
docker.io/library/postgres      14.5-alpine  a762fe0bf572  4 weeks ago   220 MB
mcr.microsoft.com/mssql/server  2019-latest  e3afdc6d8e5c  2 years ago   1.48 GB
mcr.microsoft.com/mssql/server  2022-latest  72ace9e68031  11 days ago   1.59 GB
docker.io/gvenzl/oracle-xe      21.3.0-slim  8c74998e130b  2 years ago   2.08 GB
docker.io/gvenzl/oracle-free    23.5-slim    e2b96e7b0743  9 days ago    1.82 GB
```

Spațiul ocupat de volumele containerelor (total ~3.2 GB):
```
$ du -h pbd_data/backups/podman/*
137M    pbd_data/backups/podman/mariadb-volume.bak
107M    pbd_data/backups/podman/mssql-volume.bak
2,8G    pbd_data/backups/podman/oracle-volume.bak
68M    pbd_data/backups/podman/pg-volume.bak
```

Am folosit imagini oficiale slim pentru Oracle DB, dar tot ocupă foarte mult în comparație cu alternativele.
Sunt și niște imagini cu tag "faststart", însă nu ne oferă vreun avantaj aici și ocupă ceva mai mult.
Detalii pe paginile oficiale:
[Oracle Free](https://hub.docker.com/r/gvenzl/oracle-free),
[Oracle XE](https://hub.docker.com/r/gvenzl/oracle-xe).

Mai nou, Oracle a decis să ofere versiunea 23c/23ai complet gratuit și în scopuri comerciale (cu niște limitări, desigur),
însă nerecomandată pentru uz comercial din motive de securitate.
Pentru instalare, detalii [aici](https://hub.docker.com/r/gvenzl/oracle-free) și/sau [aici](https://www.oracle.com/database/free/faq/).

Prefer să folosesc containere ca să nu ruleze non-stop ca procese de tip serviciu și ca să le pot șterge/reface mai ușor.
Prefer podman în loc de docker deoarece nu necesită drepturi de admin în mod uzual.

Containerele sunt de fapt mașini virtuale pe Windows și pe macOS. Oracle DB 23ai este disponibilă și direct pe Windows.

Oracle DB 23ai/23c se poate descărca de [aici](https://www.oracle.com/database/free/get-started/).
Oracle DB XE se poate descărca de [aici](https://www.oracle.com/database/technologies/xe-downloads.html).

Pe macOS (din ce am auzit/citit) este posibil să fie nevoie de setări în plus ca să meargă rețeaua.
Vedeți eventual cu [colima](https://github.com/abiosoft/colima).

### Setup Oracle Database Free

#### TL;DR

1. Creăm un container (imaginea este trasă automat dacă nu există local):
```bash
$ podman create \
    --name=oracle-free-container \
    -p 1521:1521 \
    --env ORACLE_PASSWORD=admin_pass1 \
    --env APP_USER=first_user \
    --env APP_USER_PASSWORD=userpass \
    --volume oracle-free-volume:/opt/oracle/oradata \
    gvenzl/oracle-free:23.5-slim
```

2. Pornim containerul:
```bash
$ podman start -ia oracle-free-container
```

3. Ne conectăm cu un client SQL:
- ca admin:
  - username: `sys` sau `SYS` (SQL nu ține cont de majuscule... cel puțin aici nu pare să țină cont)
  - **role: `SYSDBA` sau `SYSOPER`**
  - password: `admin_pass1` (cea pe care am configurat-o mai sus)
  - port: 1521 (configurat când am creat containerul)
  - SID: `free`
- ca user normal:
  - username: `first_user` (configurat mai sus sau creat de admin, vezi mai jos)
  - password: `userpass` (configurat mai sus sau creat de admin, vezi mai jos)
  - port: 1521
  - nu ne conectăm cu `SID`, ci cu **`Service name`: `FREEPDB1`**

4. Rulăm script-urile pentru creat/populat tabelele
 - creare tabele schema HR
 - inserare date schema HR
 - creare tabele și inserare date schemele project și video

#### Cleanup
```bash
$ podman rm oracle-free-container
$ podman volume rm oracle-free-volume
```

#### Detaliat:

Dacă vrem să verificăm că există imaginea în registry înainte să o descărcăm:
```
$ podman search docker.io/gvenzl/oracle-free
INDEX       NAME                           DESCRIPTION
docker.io   docker.io/gvenzl/oracle-free   Oracle Database Free for everyone! :)
docker.io   docker.io/gvenzl/oracle-xe     Oracle Database XE (21c, 18c, 11g) for every...
```

Apoi așteptăm să se descarce imaginea:
```
$ podman pull docker.io/gvenzl/oracle-free:23.5-slim
Trying to pull docker.io/gvenzl/oracle-free:23.5-slim...
Getting image source signatures
Copying blob b59615076daf done  
Copying blob aae0b9015d6b done
Copying blob d49c56a3b4c5 done
Copying blob 7fbadbe7b62e done
Copying blob beb1a1821121 done
Copying blob f669ff51d1ae done
Copying config e2b96e7b07 done  
Writing manifest to image destination
Storing signatures
e2b96e7b07439daa2f8c2f5cc829b759c7274a80342cb6866a820753cc44d134
```

Verificăm că există imaginea:
```
$ podman images
REPOSITORY                    TAG         IMAGE ID     CREATED      SIZE
docker.io/gvenzl/oracle-free  23.5-slim   e2b96e7b07   9 days ago   1.82 GB
```

Creăm un container:
```bash
$ podman create --name=oracle-free-container \
                -p 1521:1521 \
                -e ORACLE_PASSWORD=admin_pass1 \
                -v oracle-free-volume:/opt/oracle/oradata \
                gvenzl/oracle-free:23.5.0-slim
025ba033ba5596aabd600485f411c7fa332c2561c80dd185811d3b270471990e
```
Sau, dacă dorim să fie creat automat și un user normal:
```bash
$ podman create \
    --name=oracle-free-container \
    -p 1521:1521 \
    --env ORACLE_PASSWORD=admin_pass1 \
    --env APP_USER=first_user \
    --env APP_USER_PASSWORD=userpass \
    --volume oracle-free-volume:/opt/oracle/oradata \
    gvenzl/oracle-free:23.5-slim
```

Apoi pornim containerul; scoatem `-ia` dacă nu vrem să vedem logs, dar prefer să le văd și să pot opri mai simplu cu <kbd>Ctrl</kbd>+<kbd>C</kbd>.
Prima dată se face un setup inițial care durează ceva mai mult:
```
$ podman start -ia oracle-free-container
CONTAINER: starting up...
CONTAINER: first database startup, initializing...
CONTAINER: uncompressing database data files, please wait...
CONTAINER: done uncompressing database data files, duration: 3 seconds.
CONTAINER: starting up Oracle Database...

LSNRCTL for Linux: Version 23.0.0.0.0 - for Oracle Cloud and Engineered Systems on 01-OCT-2024 17:28:30

Copyright (c) 1991, 2024, Oracle.  All rights reserved.

Starting /opt/oracle/product/23ai/dbhomeFree/bin/tnslsnr: please wait...

TNSLSNR for Linux: Version 23.0.0.0.0 - for Oracle Cloud and Engineered Systems
System parameter file is /opt/oracle/product/23ai/dbhomeFree/network/admin/listener.ora
Log messages written to /opt/oracle/diag/tnslsnr/65740634cc2b/listener/alert/log.xml
Listening on: (DESCRIPTION=(ADDRESS=(PROTOCOL=ipc)(KEY=EXTPROC_FOR_FREE)))
Listening on: (DESCRIPTION=(ADDRESS=(PROTOCOL=tcp)(HOST=0.0.0.0)(PORT=1521)))

Connecting to (DESCRIPTION=(ADDRESS=(PROTOCOL=IPC)(KEY=EXTPROC_FOR_FREE)))
STATUS of the LISTENER
------------------------
Alias                     LISTENER
Version                   TNSLSNR for Linux: Version 23.0.0.0.0 - for Oracle Cloud and Engineered Systems
Start Date                01-OCT-2024 17:28:31
Uptime                    0 days 0 hr. 0 min. 0 sec
Trace Level               off
Security                  ON: Local OS Authentication
SNMP                      OFF
Default Service           FREE
Listener Parameter File   /opt/oracle/product/23ai/dbhomeFree/network/admin/listener.ora
Listener Log File         /opt/oracle/diag/tnslsnr/65740634cc2b/listener/alert/log.xml
Listening Endpoints Summary...
  (DESCRIPTION=(ADDRESS=(PROTOCOL=ipc)(KEY=EXTPROC_FOR_FREE)))
  (DESCRIPTION=(ADDRESS=(PROTOCOL=tcp)(HOST=0.0.0.0)(PORT=1521)))
The listener supports no services
The command completed successfully
ORACLE instance started.

Total System Global Area 1603726632 bytes
Fixed Size		    5360936 bytes
Variable Size		  771751936 bytes
Database Buffers	  822083584 bytes
Redo Buffers		    4530176 bytes
Database mounted.
Database opened.

CONTAINER: Resetting SYS and SYSTEM passwords.

User altered.


User altered.

CONTAINER: Creating app user for default pluggable database.

Session altered.


User created.


Grant succeeded.

CONTAINER: DONE: Creating app user for default pluggable database.

#########################
DATABASE IS READY TO USE!
#########################

####################################################################
CONTAINER: The following output is now from the alert_FREE.log file:
####################################################################
===========================================================
2024-10-01T17:28:41.648884+00:00
PDB$SEED(2):Opening pdb with Resource Manager plan: DEFAULT_PLAN
(3):--ATTENTION--
(3):PARALLEL_MAX_SERVERS (with value 1) is insufficient. This may affect transaction recovery performance.
Modify PARALLEL_MAX_SERVERS parameter to a value > 4 (= parallel servers count computed from parameter FAST_START_PARALLEL_ROLLBACK) in PDB ID 3
FREEPDB1(3):Autotune of undo retention is turned on. 
FREEPDB1(3):Opening pdb with Resource Manager plan: DEFAULT_PLAN
Completed: Pluggable database FREEPDB1 opened read write 
Completed: ALTER DATABASE OPEN
```

Trebuie să vedem următorul text în logs ca să știm că DB a pornit și că merge să ne conectăm:
```
#########################
DATABASE IS READY TO USE!
#########################
```

Avem nevoie să ne creăm useri ca să nu lucrăm pe baza de date principală cu drepturi de admin full.
Dacă nu am folosit comanda care creează și un utilizator normal sau vrem și alți utilizatori, avem 2 variante:
a. Varianta 1: Ne logăm ca admin dintr-un client SQL, apoi
```sql
ALTER SESSION SET CONTAINER=FREEPDB1;
CREATE USER grupa36x IDENTIFIED BY "parola36x" QUOTA UNLIMITED ON USERS;

GRANT CONNECT, RESOURCE, CREATE VIEW, CREATE MATERIALIZED VIEW, CREATE SYNONYM
    TO grupa36x;  
```
b. Varianta 2:
Din container folosim un script predefinit numit `createAppUser`:
```bash
$ podman exec -it oracle-free-container bash
# din container
$ createAppUser grupa36x parola1
```

Din nefericire, script-ul primește parola ca argument, nu o citește de la stdin.
Astfel, parola va rămâne în istoricul terminalului. Pentru testare, este irelevant. Dacă ne interesează, parola poate fi schimbată ulterior.

:warning: Atenție! Nu vom folosi utilizatorul admin în mod uzual.
Este de preferat să ne creăm useri cu drepturi (privilegii) limitate care să nu aibă posibilitatea să arunce în aer toată BD :boom:

Pentru credențialele bazei de date a facultății, veniți la ore :smile:

PDB vine de la pluggable database (specific Oracle; detalii [aici](https://www.databasestar.com/oracle-pdb/)).
Implicit, este deja creată o bază de date pluggable: FREEPDB1.

Dacă vrem să verificăm că așa se numește, rulăm logați ca admin:
```sql
SELECT name, pdb FROM v$services;
```

Script-ul din container `createAppUser` ar trebui să ne ofere drepturile de care avem nevoie în mod uzual.
Dacă totuși nu avem suficiente drepturi cu userul normal, folosim din nou adminul:
```sql
CREATE USER grupa IDENTIFIED BY parola QUOTA UNLIMITED ON USERS;
-- "users" pare să fie default tablespace

GRANT CREATE SESSION, CREATE TABLE, CREATE VIEW, CREATE SEQUENCE TO grupa;
-- etc
-- comenzile sunt similare pentru funcții, proceduri, triggeri, tipuri de date
-- pentru schimbat parola, comanda ar trebui să fie ALTER USER grupa IDENTIFIED by Passw0rd;
```

Pe DB de la facultate nu avem drepturi de admin, deci nu avem acces la tabele, vizualizări etc. de sistem (de exemplu majoritatea cu `v$`).

În Oracle DB, un user este echivalent cu o schemă, deci un user nu poate avea mai multe scheme.
Dacă avem nevoie de o nouă schemă, o creăm cu sintaxa `CREATE USER`.
Pentru acordarea mai multor drepturi deodată, folosim sintaxa `CREATE SCHEMA`.
Detalii [aici](https://docs.oracle.com/en/database/oracle/oracle-database/23/sqlrf/CREATE-SCHEMA.html).

#### Despre licențe și Oracle

Nu sunt avocat, nu vă bazați pe informațiile din această secțiune.

Bazele de date Oracle pot fi folosite în mod gratuit dacă nu este vorba de scopuri comerciale. Edițiile principale sunt:
- FREE (23ai/23c Free Developer Edition): pentru dezvoltare și testare
  - pare să dea voie să fie folosită în scopuri comerciale, probabil ca să nu își piardă dominanța pe piață
  - are numeroase limitări: memorie RAM, spațiu pe disc, actualizarea versiunii (trebuie upgrade de la zero, nu are patches)
- XE (express edition): de regulă cu scop educațional și pentru testare
  - [aparent](https://asktom.oracle.com/pls/apex/f?p=100:11:::NO:RP:P11_QUESTION_ID:9536759800346388355) poate fi folosită gratuit pentru scopuri comerciale
  - aceleași restricții ca la ediția FREE
- SE (standard edition): licențe pe bani
  - are activate "din fabrică" numeroase facilități care pot fi folosite fără licență, ceea ce duce la încălcarea termenilor și condițiilor
  - înainte de utilizarea bazei de date, aceste facilități ar trebui dezactivate; procesul pare unul foarte complicat și anevoios
  - cu alte cuvinte, dacă nu știi de chichițele cu licențele, folosești fără să vrei/știi facilități premium fără licență, iar apoi vin să te controleze și te amendează
- EE (enterprise edition): licențe pe și mai mulți bani

<p align=center>
  <a href="https://user-images.githubusercontent.com/23401453/190024309-0da4d6ef-2fa7-41e0-a5ac-2190a1d931bf.png">
    <img src="https://user-images.githubusercontent.com/23401453/190024213-4948b69c-16d5-41c6-a5c4-f7fb7c8043ba.png" alt="big tech company org charts"/>
  </a>
</p>
<p align=right><a href="https://images.fastcompany.net/image/upload/fc/3046512-inline-3-organizationalcharts.png">(sursa imaginii)</a></p>

Noi folosim varianta FREE pentru că celelalte variante ocupă mult prea mult spațiu și oricum nu ne interesează facilitățile în plus.

Din ce înțeleg, putem identifica (o parte din) aceste facilități cu următoarea cerere:
```sql
SELECT PARAMETER name, value
FROM v$option vo
ORDER BY 2 DESC, 1;
```

Rezultatul (trunchiat) pe FREE 23.5 este:
```
NAME                        VALUE
---------------------------------
Adaptive Execution Plans    TRUE
Advanced Analytics          TRUE
...
XStream                     TRUE
Zone Maps                   TRUE
ASM Proxy Instance          FALSE
Active Data Guard           FALSE
...
Server Flash Cache          FALSE
Streams Capture             FALSE
```

Referitor la performanța SGBD-urilor closed-source (nu doar Oracle), este împotriva termenilor și condițiilor să publicăm [benchmarks](https://stackoverflow.com/a/12116865).


### Setup Microsoft SQL Server

Detalii despre imagine aici: https://hub.docker.com/_/microsoft-mssql-server

Din terminal:
```
$ podman pull mcr.microsoft.com/mssql/server:2022-latest
$ podman create --name=mssql-2022-xe-container \
                -p 1433:1433 \
                -e "SA_PASSWORD=admin_pass1" \
                -e "ACCEPT_EULA=Y" \
                -e "MSSQL_PID=Express" \
                -v mssql-2022-volume:/var/opt/mssql/data \
                mssql/server:2022-latest
$ podman start -ia mssql-2022-xe-container
```

Este necesar să dăm fiecare privilegiu separat. La fel ca mai sus, dorim să ne
creăm o bază de date separată și un user cu mai puține privilegii.

Din clientul SQL rulăm ca admin script-urile din repo în ordine:
- create tables
- create view
- insert data
- add foreign keys

Apoi creăm user-ul și îi dăm drepturi:
```sql
SELECT @@version;

-- o singură dată pentru un user
CREATE LOGIN seria36
WITH PASSWORD = 'M$_login1', CHECK_POLICY = OFF;


-- pentru fiecare DB/schemă în parte trebuie comenzile de mai jos
USE hr;
CREATE USER seria36
FOR LOGIN seria36;

GRANT EXECUTE, SHOWPLAN TO seria36;
GRANT ALTER ON SCHEMA::dbo TO seria36;
--GRANT CREATE DATABASE TO seria36;
GRANT CREATE TABLE, REFERENCES, CREATE TYPE, CREATE FUNCTION, CREATE PROCEDURE TO seria36;
GRANT INSERT, SELECT, UPDATE, DELETE ON SCHEMA::dbo TO seria36;
-- GRANT CREATE TRIGGER TO seria36; -- probabil e implicit din table

--GRANT ALL TO seria36; -- deprecated
--REVOKE ALL TO seria36;

COMMIT;
-- până aici (de la acel "USE hr")

USE master;
```

Pentru a face curat:
```sql
-- cleanup
USE master;

DROP USER seria36;
DROP LOGIN seria36;
DROP DATABASE hr;
```

La fel ca toate produsele Microsoft, SQL Server se bazează (prea mult) pe interfața grafică (GUI),
ceea ce face anevoios procesul de configurare fără GUI (nu mai vorbim de automatizare).
Conform documentației, SQL Server pare să ofere posibilitatea unui user să aibă mai multe scheme, însă acordarea permisiunilor este un chin.

### Setup MariaDB

MariaDB este un fork din MySQL și pentru ce avem noi nevoie le vom considera echivalente.
Prefer MariaDB în detrimentul MySQL deoarece MySQL este cumpărat de Oracle și ne ajunge o bază de date Oracle.

Din terminal:
```
$ podman pull docker.io/mariadb:11.4.3
$ podman create --name=mariadb-11-container \
                -p 3306:3306 \
                -e "MARIADB_ROOT_PASSWORD=my-secret-pw" \
                -e "MARIADB_DATABASE=hr" \
                -e "MARIADB_USER=seria36" \
                -e "MARIADB_PASSWORD=mariadb_pw" \
                -v mariadb-11-volume:/var/lib/mysql \
                mariadb:11.4.3
$ podman start -ia mariadb-11-container
# stop with
$ podman stop mariadb-11-container
```

Putem rula direct script-ul din contextul utilizatorului normal pentru a crea tabelele și a insera datele.

Opțional, din clientul SQL ca admin verificăm că avem deja drepturi pentru utilizatorul normal:
```sql
SHOW GRANTS FOR seria36;
-- GRANT ALL PRIVILEGES ON hr.* TO seria36; -- dacă este cazul
```

În MariaDB/MySQL, un user nu poate avea mai multe scheme, dar poate accesa cu o conexiune tabele din mai multe baze de date.

Pentru imagini alpine (neoficiale): https://hub.docker.com/r/yobasystems/alpine-mariadb

Pentru MySQL, comenzile de mai sus sunt identice:
```
$ podman pull docker.io/mysql:8.4.2
$ podman create --name=mysql-8.4-container \
                -p 3306:3306 \
                -e "MYSQL_ROOT_PASSWORD=my-secret-pw" \
                -e "MYSQL_DATABASE=hr" \
                -e "MYSQL_USER=seria36" \
                -e "MYSQL_PASSWORD=mysql_pw" \
                -v mysql-8.4-volume:/var/lib/mysql \
                mysql:8.4.2
$ podman start -ia mysql-8.4-container
# stop with
$ podman stop mysql-8.4-container
```

### Setup PostgreSQL

Din terminal:
```
$ podman pull docker.io/postgres:17.0-alpine
$ podman create --name=postgres-17-container \
                -p 5432:5432 \
                -e "POSTGRES_PASSWORD=pg-password" \
                -v pg-17-volume:/var/lib/postgresql/data \
                postgres:17.0-alpine
$ podman start -ia postgres-17-container
```

Dacă folosiți DBeaver, trebuie să configurați "Database->Transaction mode->Auto-Commit" (eventual fără "Smart commit mode").

Din clientul SQL ca admin, executate **pe rând**:
```sql
CREATE USER seria36 WITH PASSWORD 'Pg=passwd2!';

CREATE DATABASE pbd;

GRANT ALL PRIVILEGES ON DATABASE pbd TO seria36;

-- cleanup
DROP DATABASE pbd;
DROP USER seria36;
```

Din clientul SQL ca user simplu după ce am rulat script-ul:
```sql
SET search_path TO hr;

SELECT COUNT(*) FROM employees e ;

--CREATE SCHEMA test_schema;
--SHOW search_path;

-- SET search_path TO test_schema;
SELECT COUNT(*) FROM employees e ;
SHOW search_path;
```

În PostgreSQL, un user poate avea mai multe scheme, dar implicit nu poate accesa cu o conexiune tabele din mai multe baze de date.

### Setup SQLite

Nu este nimic de configurat. SQLite este o bază de date la nivel de fișier.
Baza de date cu totul este un singur fișier. Interacțiunea se face cu ajutorul unor biblioteci.

Având în vedere că toată baza de date este un singur fișier, nu există conceptul de utilizatori.
Sarcina acordării drepturilor revine sistemului de operare sau aplicațiilor care interacționează cu baza de date.

Din clientul SQL, singurul lucru pe care trebuie să îl facem este să selectăm fișierul cu baza de date.
