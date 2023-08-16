# Proiectarea Bazelor de Date

### Introducere

Termenul de "bază de date" (BD sau DB) se poate referi la:
- bază de date la nivel de SQL: `CREATE DATABASE test_db;`
- sistem de gestiune a bazelor de date (SGBD/DBMS)

SGBD-urile relaționale cele mai întâlnite sunt Oracle, MySQL/MariaDB, Microsoft SQL Server, PostgreSQL și SQLite.
Ar mai fi și altele, dar nu prea sunt alese în practică pentru proiecte noi, motiv pentru care nu le consider de interes.

În majoritatea situațiilor de mai jos, prin bază de date ne referim de fapt la SGBD.

Pentru a ne conecta la o bază de date, avem nevoie de un client SQL. Exemple: Oracle SQL Developer, DataGrip, DBeaver, sqlplus, psql.

Avem mai multe motive să ne creăm o bază de date locală pe lângă baza de date de la facultate:
- drepturi de admin ca să înțelegem mai bine ce se întâmplă
- acces la versiuni mai noi
- loc de experimentat fără să fie vreo problemă dacă stricăm ceva esențial
- soluție de backup dacă nu merge BD a facultății

### Cerințe preliminare
- minim 8-10 GB spațiu liber pe disc
  - avem nevoie de spațiu atât pentru SGBD-uri, cât și pentru programele ajutătoare
  - bazele de date create de noi nu ar trebui să ocupe mai mult de câțiva MB
- instalare ~~[`docker`](https://docs.docker.com/engine/install/) și [`docker-compose`](https://docs.docker.com/compose/install/)~~ [`podman`](https://podman.io/getting-started/installation)

Spațiul ocupat de imagini (total ~4.2 GB):
```
$ podman images
REPOSITORY                      TAG          IMAGE ID      CREATED       SIZE
docker.io/library/mariadb       10.9         01d138caf7d0  2 weeks ago   391 MB
docker.io/library/postgres      14.5-alpine  a762fe0bf572  4 weeks ago   220 MB
mcr.microsoft.com/mssql/server  2019-latest  e3afdc6d8e5c  7 weeks ago   1.48 GB
docker.io/gvenzl/oracle-xe      21.3.0-slim  8c74998e130b  2 months ago  2.08 GB
```

Spațiul ocupat de volumele containerelor (total ~3.2 GB):
```
$ du -h pbd_data/backups/podman/*
137M    pbd_data/backups/podman/mariadb-volume.bak
107M    pbd_data/backups/podman/mssql-volume.bak
2,8G    pbd_data/backups/podman/oracle-volume.bak
68M    pbd_data/backups/podman/pg-volume.bak
```

Am folosit imagini oficiale slim pentru Oracle DB Express Edition (XE), dar tot ocupă foarte mult în comparație cu alternativele.
După ce mi-am configurat local Oracle, au apărut și imagini cu tag "faststart", însă nu ne oferă vreun avantaj aici.
Detalii pe pagina oficială: https://hub.docker.com/r/gvenzl/oracle-xe

Mai nou, Oracle a decis să ofere versiunea 23c complet gratuit, însă nerecomandată pentru uz comercial din motive de securitate.
Pentru instalare, detalii [aici](https://hub.docker.com/r/gvenzl/oracle-free) și/sau [aici](https://www.oracle.com/database/free/faq/).

Prefer să folosesc containere ca să nu ruleze non-stop ca procese de tip serviciu și ca să le pot șterge/reface mai ușor.
Prefer podman în loc de docker deoarece nu necesită drepturi de admin în mod uzual.

Containerele sunt de fapt mașini virtuale pe Windows și pe macOS. Momentan (august 2023), Oracle DB 23c nu este disponibilă direct pe Windows.

Oracle DB 23c se poate descărca de [aici](https://www.oracle.com/database/free/download/).
Oracle DB XE se poate descărca de [aici](https://www.oracle.com/database/technologies/xe-downloads.html).

Pe macOS (din ce am auzit/citit) este posibil să fie nevoie de setări în plus ca să meargă rețeaua.
Vedeți cu [colima](https://github.com/abiosoft/colima).

### Setup Oracle DB XE

Pentru versiunea 23c, înlocuiți mai jos `oracle-xe` cu `oracle-free` și `21.3.0-slim` cu `23.2-slim`.

Dacă vrem să verificăm că există imaginea în registry înainte să o descărcăm:
```
$ podman search docker.io/gvenzl/oracle-xe
INDEX       NAME                        DESCRIPTION                                      STARS       OFFICIAL    AUTOMATED
docker.io   docker.io/gvenzl/oracle-xe  Oracle Database XE (21c, 18c, 11g) for every...  80
```

Apoi așteptăm să se descarce imaginea:
```
$ podman pull docker.io/gvenzl/oracle-xe:21.3.0-slim
Trying to pull docker.io/gvenzl/oracle-xe:21.3.0-slim...
Getting image source signatures
Copying blob f4069ceb7689 done  
Copying blob 50b5143a8e9f done  
Copying config 8c74998e13 done  
Writing manifest to image destination
Storing signatures
8c74998e130b45f3923bb24d51aafcb400bf06cc451a18bd1270ef4fd0f9a6a6
```

Verificăm că există imaginea:
```
$ podman images
REPOSITORY                  TAG          IMAGE ID      CREATED      SIZE
docker.io/gvenzl/oracle-xe  21.3.0-slim  8c74998e130b  3 weeks ago  2.08 GB
```

Creăm un container:
```
$ podman create --name=oracle-xe-container \
                -p 1521:1521 \
                -e ORACLE_PASSWORD=admin_pass1 \
                -v oracle-volume:/opt/oracle/oradata \
                gvenzl/oracle-xe:21.3.0-slim
d35125f29eea1d1ba5ff4a98dd3fdf1c3be309154acddfb8e1151af3ebf5da7e
```

Apoi pornim containerul (scoatem `-ia` dacă nu vrem să vedem logs).
Prima dată se face un setup inițial care durează ceva mai mult:
```
$ podman start -ia oracle-xe-container
CONTAINER: done uncompressing database data files, duration: 17 seconds.
CONTAINER: starting up Oracle Database...

LSNRCTL for Linux: Version 21.0.0.0.0 - Production on 29-JUL-2022 20:15:29

Copyright (c) 1991, 2021, Oracle.  All rights reserved.

Starting /opt/oracle/product/21c/dbhomeXE/bin/tnslsnr: please wait...

TNSLSNR for Linux: Version 21.0.0.0.0 - Production
System parameter file is /opt/oracle/homes/OraDBHome21cXE/network/admin/listener.ora
Log messages written to /opt/oracle/diag/tnslsnr/d35125f29eea/listener/alert/log.xml
Listening on: (DESCRIPTION=(ADDRESS=(PROTOCOL=ipc)(KEY=EXTPROC_FOR_XE)))
Listening on: (DESCRIPTION=(ADDRESS=(PROTOCOL=tcp)(HOST=0.0.0.0)(PORT=1521)))

Connecting to (DESCRIPTION=(ADDRESS=(PROTOCOL=IPC)(KEY=EXTPROC_FOR_XE)))
STATUS of the LISTENER
------------------------
Alias                     LISTENER
Version                   TNSLSNR for Linux: Version 21.0.0.0.0 - Production
Start Date                29-JUL-2022 20:15:29
Uptime                    0 days 0 hr. 0 min. 0 sec
Trace Level               off
Security                  ON: Local OS Authentication
SNMP                      OFF
Default Service           XE
Listener Parameter File   /opt/oracle/homes/OraDBHome21cXE/network/admin/listener.ora
Listener Log File         /opt/oracle/diag/tnslsnr/d35125f29eea/listener/alert/log.xml
Listening Endpoints Summary...
  (DESCRIPTION=(ADDRESS=(PROTOCOL=ipc)(KEY=EXTPROC_FOR_XE)))
  (DESCRIPTION=(ADDRESS=(PROTOCOL=tcp)(HOST=0.0.0.0)(PORT=1521)))
The listener supports no services
The command completed successfully
ORACLE instance started.

Total System Global Area 1241512272 bytes
Fixed Size		    9685328 bytes
Variable Size		  671088640 bytes
Database Buffers	  553648128 bytes
Redo Buffers		    7090176 bytes
Database mounted.
Database opened.

CONTAINER: Resetting SYS and SYSTEM passwords.

User altered.


User altered.


#########################
DATABASE IS READY TO USE!
#########################

##################################################################
CONTAINER: The following output is now from the alert_XE.log file:
##################################################################
XEPDB1(3):Opening pdb with Resource Manager plan: DEFAULT_PLAN
Pluggable database XEPDB1 opened read write
2022-07-29T20:15:41.370795+00:00
Resize operation completed for file# 201, fname /opt/oracle/oradata/XE/temp01.dbf, old size 2048K, new size 12288K
Starting background process CJQ0
2022-07-29T20:15:41.454790+00:00
CJQ0 started with pid=55, OS id=196 
Completed: ALTER DATABASE OPEN
2022-07-29T20:15:41.535385+00:00
Using default pga_aggregate_limit of 2048 MB
2022-07-29T20:15:43.470882+00:00
TABLE SYS.WRP$_REPORTS: ADDED INTERVAL PARTITION SYS_P381 (4593) VALUES LESS THAN (TO_DATE(' 2022-07-30 01:00:00', 'SYYYY-MM-DD HH24:MI:SS', 'NLS_CALENDAR=GREGORIAN'))
TABLE SYS.WRP$_REPORTS_DETAILS: ADDED INTERVAL PARTITION SYS_P382 (4593) VALUES LESS THAN (TO_DATE(' 2022-07-30 01:00:00', 'SYYYY-MM-DD HH24:MI:SS', 'NLS_CALENDAR=GREGORIAN'))
TABLE SYS.WRP$_REPORTS_TIME_BANDS: ADDED INTERVAL PARTITION SYS_P385 (4592) VALUES LESS THAN (TO_DATE(' 2022-07-29 01:00:00', 'SYYYY-MM-DD HH24:MI:SS', 'NLS_CALENDAR=GREGORIAN'))
```

Trebuie să vedem următorul text în logs ca să știm că DB a pornit și că merge să ne conectăm:
```
#########################
DATABASE IS READY TO USE!
#########################
```

Avem nevoie să ne creăm useri ca să nu lucrăm pe baza de date principală cu drepturi de admin full.
Ne conectăm fie din container, fie din clientul SQL (sau alt client), momentan ca admini:
```
$ podman exec -it oracle-xe-container bash
```

Imaginea are un script predefinit `createAppUser`:
```
$ createAppUser grupa36x parola1
```

Din nefericire, script-ul primește parola ca argument, nu o citește de la stdin.
Astfel, parola va rămâne în istoricul terminalului. Dacă ne interesează, parola poate fi schimbată ulterior.

Ca să ne conectăm ca admini, fie folosim userul `SYSTEM` și introducem manual parola, fie cu `sqlplus / as sysdba`:
```
$ sqlplus / as sysdba

SQL*Plus: Release 21.0.0.0.0 - Production on Fri Jul 29 20:44:06 2022
Version 21.3.0.0.0

Copyright (c) 1982, 2021, Oracle.  All rights reserved.


Connected to:
Oracle Database 21c Express Edition Release 21.0.0.0.0 - Production
Version 21.3.0.0.0
```

:warning: Atenție! Nu vom folosi în mod uzual acest user.
Este de preferat să ne creăm useri cu drepturi (privilegii) limitate care să nu aibă posibilitatea să arunce în aer toată BD :boom:

Ca să ne conectăm ca useri normali, folosim `sqlplus` sau un alt client SQL. Din sqlplus arată așa:
```
$ sqlplus grupa36x@XEPDB1
```

Nu am vrea să introducem și parola direct în acea comandă ca să nu rămână în istoricul terminalului.

Pentru a ne conecta cu un client SQL:
- ca admin:
  - username: `sys` sau `SYS` (SQL nu ține cont de majuscule... cel puțin aici nu pare să țină cont)
  - **role: `SYSDBA` sau `SYSOPER`**
  - password: `admin_pass1` (cea pe care am configurat-o mai sus)
  - port: 1521 (configurat când am creat containerul)
  - SID: `xe` (de la express edition)
- ca user normal:
  - username: `grupa36x`
  - password: `parola1`
  - port: 1521
  - nu ne conectăm cu `SID`, ci cu `Service name`: `XEPDB1`

Pentru credențialele bazei de date a facultății, veniți la ore :smile:

PDB vine de la pluggable database (specific Oracle; detalii [aici](https://www.databasestar.com/oracle-pdb/)).
Implicit, este deja creată o bază de date pluggable: XEPDB1.

Dacă vrem să verificăm că așa se numește, rulăm logați ca admin:
```sql
SELECT name, pdb FROM v$services;
```

Script-ul din container `createAppUser` ar trebui să ne ofere drepturile de care avem nevoie în mod uzual.
Dacă totuși nu avem suficiente drepturi cu userul normal, folosim din nou adminul:
```sql
CREATE USER grupa IDENTIFIED BY parola;

GRANT CREATE SESSION TO grupa;
GRANT CREATE TABLE TO grupa;
GRANT CREATE VIEW TO grupa;
GRANT CREATE SEQUENCE TO grupa;
-- etc
-- comenzile sunt similare pentru funcții, proceduri, triggeri, tipuri de date

ALTER USER grupa DEFAULT TABLESPACE users QUOTA unlimited ON users;
-- "users" pare să fie default tablespace

-- pentru schimbat parola, comanda ar trebui să fie ALTER USER grupa IDENTIFIED by Passw0rd;
```

Pe DB de la facultate nu avem drepturi de admin, deci nu avem acces la tabele, vizualizări etc. de sistem (de exemplu cele cu `v$`).

În Oracle DB, un user este echivalent cu o schemă, deci un user nu poate avea mai multe scheme.
Dacă avem nevoie de o nouă schemă, o creăm cu sintaxa `CREATE USER`.
Pentru acordarea mai multor drepturi deodată, folosim sintaxa `CREATE SCHEMA`.
Detalii [aici](https://docs.oracle.com/cd/B19306_01/server.102/b14200/statements_6014.htm).

#### Despre licențe și Oracle

Nu sunt avocat, nu vă bazați pe informațiile din această secțiune.

Bazele de date Oracle pot fi folosite în mod gratuit dacă nu este vorba de scopuri comerciale. Edițiile principale sunt:
- XE (express edition): de regulă cu scop educațional și pentru testare
  - [aparent](https://asktom.oracle.com/pls/apex/f?p=100:11:::NO:RP:P11_QUESTION_ID:9536759800346388355) poate fi folosită gratuit pentru scopuri comerciale
  - are numeroase limitări: memorie RAM, spațiu pe disc, actualizarea versiunii (trebuie upgrade de la zero, nu are patches)
  - aceleași restricții sunt și la 23c Free Developer Edition
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

Noi folosim varianta XE pentru că celelalte variante ocupă mult prea mult spațiu și oricum nu ne interesează facilitățile în plus.
În mod curios, pe XE mai noi sunt incluse facilități premium care nu sunt disponibile în SE.

Din ce înțeleg, putem identifica (o parte) din aceste facilități cu următoarea cerere:
```sql
SELECT PARAMETER name, value
FROM "v$option" vo
ORDER BY 2 DESC, 1;
```

Rezultatul (trunchiat) pe XE 21.3 este:
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
Streams Capture             FALSE
Unified Auditing            FALSE
```

Referitor la performanța SGBD-urilor closed-source (nu doar Oracle), este împotriva termenilor și condițiilor să publicăm [benchmarks](https://stackoverflow.com/a/12116865).

### Setup Microsoft SQL Server

Detalii despre imagine aici: https://hub.docker.com/_/microsoft-mssql-server

Din terminal:
```
$ podman pull mcr.microsoft.com/mssql/server:2019-latest
$ podman create --name=mssql-xe-container \
                -p 1433:1433 \
                -e "SA_PASSWORD=admin_pass1" \
                -e "ACCEPT_EULA=Y" \
                -e "MSSQL_PID=Express" \
                -v mssql-volume:/var/opt/mssql/data \
                mssql/server:2019-latest
$ podman start -ia mssql-xe-container
```

Este necesar să dăm fiecare privilegiu separat. La fel ca mai sus, dorim să ne
creăm o bază de date separată și un user cu mai puține privilegii.

Din clientul SQL:
```sql
SELECT @@version;

-- CREATE DATABASE hr; -- creăm baza de date cu scriptul din repo

-- o singură dată
CREATE LOGIN seria36
WITH PASSWORD = 'M$_login1', CHECK_POLICY = OFF;

USE hr;

-- pentru fiecare DB/schemă în parte trebuie comenzile de mai jos
CREATE USER seria36
FOR LOGIN seria36;

GRANT EXECUTE TO seria36;
GRANT ALTER ON SCHEMA::dbo TO seria36;
--GRANT CREATE DATABASE TO seria36;
GRANT CREATE TABLE TO seria36;
GRANT REFERENCES TO seria36;
GRANT INSERT, SELECT, UPDATE, DELETE ON SCHEMA::dbo TO seria36;
GRANT SHOWPLAN TO seria36;

--GRANT ALL TO seria36; -- deprecated
--REVOKE ALL TO seria36;

-- cleanup
USE master;

DROP USER seria36;
DROP LOGIN grupa36;
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
$ podman pull docker.io/mariadb:10.9
$ podman create --name=mariadb-container \
                -p 3306:3306 \
                -e "MARIADB_ROOT_PASSWORD=my-secret-pw" \
                -e "MARIADB_DATABASE=hr" \
                -e "MARIADB_USER=seria36" \
                -e "MARIADB_PASSWORD=mariadb_pw" \
                -v mariadb-volume:/var/lib/mysql \
                mariadb:10.9
$ podman start -ia mariadb-container
# stop with
$ podman stop mariadb-container
```

Din clientul SQL:
```sql
SHOW GRANTS FOR seria36;
GRANT ALL PRIVILEGES ON hr.* TO seria36;
```

În MariaDB/MySQL, un user nu poate avea mai multe scheme, dar poate accesa cu o conexiune tabele din mai multe baze de date.

Pentru imagini alpine (neoficiale): https://hub.docker.com/r/yobasystems/alpine-mariadb

### Setup PostgreSQL

Din terminal:
```
$ podman pull docker.io/postgres:14.5-alpine
$ podman create --name=postgres-container \
                -p 5432:5432 \
                -e "POSTGRES_PASSWORD=pg-password" \
                -v pg-volume:/var/lib/postgresql/data \
                postgres:14.5-alpine
$ podman start -ia postgres-container
```

Din clientul SQL ca admin:
```sql
CREATE USER seria36 WITH PASSWORD 'Pg=passwd2!';
CREATE DATABASE pbd;
GRANT ALL PRIVILEGES ON DATABASE pbd TO seria36;

-- cleanup
DROP DATABASE pbd;
DROP USER seria36;
```

Din clientul SQL ca user simplu:
```sql
SELECT COUNT(*) FROM employees e ;

--CREATE SCHEMA test_schema;
--SHOW search_path;

SET search_path TO public;
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
