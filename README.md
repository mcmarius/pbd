# Proiectarea Bazelor de Date

### Intro

There are a couple of reasons to set up a local DB aside from using the faculty DB:
- admin rights to understand what is happening more exactly
- access to new features
- playground to mess things up
- backup option if faculty DB is down

### Steps for installing Oracle DB Express Edition
- you might need at least ~~15-10~~ 10 GB of free space
  - the DB itself requires about ~~10~~ ~5 GB (if my math is correct)
  - other dependencies (like `docker`) will also require extra space, so another 5-10 GB should be safe
- you might need to close the web browser and other RAM-intensive programs (this might be old info)
- setup ~~[`docker`](https://docs.docker.com/engine/install/) and [`docker-compose`](https://docs.docker.com/compose/install/)~~ [`podman`](https://podman.io/getting-started/installation)

Mai nou există imagini oficiale slim: https://hub.docker.com/r/gvenzl/oracle-xe

Pentru Windows probabil nu merită efortul, deoarece containerele sunt
de fapt mașini virtuale pe Windows și pe macOS. Se poate descărca de aici: https://www.oracle.com/database/technologies/xe-downloads.html


```
$ podman search docker.io/gvenzl/oracle-xe
INDEX       NAME                        DESCRIPTION                                      STARS       OFFICIAL    AUTOMATED
docker.io   docker.io/gvenzl/oracle-xe  Oracle Database XE (21c, 18c, 11g) for every...  80
```

Apoi descărcăm cu `podman pull docker.io/gvenzl/oracle-xe:21.3.0-slim`. După ce e gata:
```
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
$ podman create --name=oracle-xe-container -p 1521:1521 -e ORACLE_PASSWORD=admin_pass1 -v oracle-volume:/opt/oracle/oradata gvenzl/oracle-xe:21.3.0-slim
d35125f29eea1d1ba5ff4a98dd3fdf1c3be309154acddfb8e1151af3ebf5da7e
```

Apoi pornim containerul (scoatem `-ia` dacă nu vrem să vedem logs).
Prima dată se face un setup inițial:
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

Avem nevoie să ne creăm useri ca să nu lucrăm pe baza de date principală cu drepturi de admin full.
Ne conectăm fie din container, fie din SQL Developer, momentan ca admini:
```
$ podman exec -it oracle-xe-container bash
```

Imaginea are un script predefinit `createAppUser`:
```
$ createAppUser grupa351 parola
```

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

:warning: Warning! We will not use this user on an every day basis. Instead, we need to create users with limited privileges so they are not able to blow up the whole system :boom:


Ca să ne conectăm ca useri normali, fie cu `sqlplus`, fie din SQL Developer:
```
$ sqlplus grupa351@XEPDB1
```

Nu am vrea să introducem și parola direct în acea comandă ca să nu rămână în
istoricul terminalului.

Trebuie să vedem următorul text ca să știm că db a pornit:
```
#########################
DATABASE IS READY TO USE!
#########################
```

  - from SQL Developer:
    - username: `sys` or `SYS` (since sql is case insensitive... at least in this case)
    - **role: `SYSDBA` or `SYSOPER`**
    - password: cea de mai sus; în cazul nostru, `admin_pass1`
    - port: 1521 (configurat când am creat containerul)
    - SID: `xe` (de la express edition)

Ca user normal:
- username: `grupa35x`
- password: `oracle`
- port: 1521
- nu ne conectăm cu `SID`, ci cu `Service name`: `XEPDB1`

Implicit, este deja creată o bază de date pluggable: XEPDB1.

Dacă vrem să verificăm că așa se numește, rulăm logați ca admin:
```sql
SELECT name, pdb FROM v$services;
```

// https://www.databasestar.com/oracle-pdb/

```
-- ??

alter PLUGGABLE DATABASE ALL OPEN;
alter PLUGGABLE DATABASE ALL SAVE STATE;

-- not sure when we need to reset the db to start the pdbs /shrug

create pluggable database mpdb ADMIN USER pdbadmin IDENTIFIED BY Passw0rd
roles=(DBA) file_name_convert = ('/pdbseed/', '/mpbd/');

--drop PLUGGABLE DATABASE mpdb INCLUDING DATAFILES;
```
```
-- find the pdb xe name from
cat /opt/oracle/product/21c/dbhomeXE/network/admin/tnsnames.ora 
-- connect with
user: pdbadmin
password: Passw0rd
role: default
service name (not sid): <the one from cat above> xepdb1 (in my case)

-- select * from all_users order by username;
<end of alternative to _ORACLE_SCRIPT>
```

-------

Dacă nu avem suficiente drepturi cu userul normal, folosim din nou adminul:
```
create user grupa identified by parola;

GRANT CREATE SESSION TO grupa;
GRANT CREATE TABLE TO grupa;
GRANT CREATE VIEW TO grupa;
GRANT CREATE SEQUENCE TO grupa;
-- etc
-- we will probably need to use similar commands for functions, procedures, triggers, types

alter user grupa DEFAULT TABLESPACE users quota unlimited on users;
-- "users" seems to be the default tablespace /shrug

-- reset password with something like alter user pdbadmin IDENTIFIED by Passw0rd;
```

### Other steps:
- disabling features
  - http://www.dba-oracle.com/t_dba_features_used_statistics.htm
  - http://www.dba-oracle.com/t_xe_features_oracle_express.htm
  - http://www.dba-oracle.com/t_se_features_enabled.htm
  - https://grepora.com/2019/06/05/oracle-disable-awr-and-prevent-to-violate-diagnostic-tuning/
  - https://petesdbablog.wordpress.com/2013/04/06/disable-oracle-diagnostic-pack-tuning-pack/
  - http://www.dba-oracle.com/t_tuning_pack_disable.htm

Running some (random) commands from the links above:
```
DESC dba_feature_usage_statistics;

EXEC DBMS_FEATURE_USAGE_INTERNAL.exec_db_usage_sampling(SYSDATE);

COLUMN name  FORMAT A60
COLUMN detected_usages FORMAT 999999999999

SELECT u1.name,
       u1.detected_usages,
       u1.currently_used,
       u1.version
FROM   dba_feature_usage_statistics u1
WHERE  u1.version = (SELECT MAX(u2.version)
                     FROM   dba_feature_usage_statistics u2
                     WHERE  u2.name = u1.name)
AND    u1.detected_usages > 0
AND    u1.dbid = (SELECT dbid FROM v$database)
ORDER BY name;

select * from dba_feature_usage_statistics;

show parameter control_management;


show parameter statistics_level;

col name format A30
col detected format 9999
col samples format 9999
col used format A5
col interval format 9999999

SELECT name,
       detected_usages detected,
                 total_samples   samples,
                 currently_used  used,
                 to_char(last_sample_date,'MMDDYYYY:HH24:MI') last_sample,
                 sample_interval interval
FROM dba_feature_usage_statistics
WHERE name = 'Automatic Workload Repository';

col name format A31
col detected format 9999
col samples format 9999
col used format A5
col interval format 9999999

SELECT name,       
       detected_usages detected,
       total_samples   samples,
       currently_used  used,
       to_char(last_sample_date,'MMDDYYYY:HH24:MI') last_sample,
       sample_interval interval
  FROM dba_feature_usage_statistics
 WHERE name = 'Automatic Workload Repository'     OR  name like 'SQL%';

show parameter control_management_pack_access;

select client_name, operation_name, status from dba_autotask_operation;

BEGIN
  dbms_auto_task_admin.disable(
    client_name => 'sql tuning advisor',
    operation   => NULL,
    window_name => NULL);

  dbms_auto_task_admin.disable(
    client_name => 'auto space advisor',
    operation   => NULL,
    window_name => NULL);

END;
/


set pages 999

col c1 heading 'feature'    format a45
col c2 heading 'times|used' format 999,999
col c3 heading 'first|used'
col c4 heading 'used|now'

select
   name             c1,
   detected_usages  c2,
   first_usage_date c3,
   currently_used   c4
from
   dba_feature_usage_statistics
where
   first_usage_date is not null;

select 1 from dual;
```

On the faculty DB, we do not have admin rights:
```
DESC dba_feature_usage_statistics;

show parameter control_management;
```

These result in:
```
SP2-0749: Cannot resolve circular path of synonym "dba_feature_usage_statistics"
Show parameters query failed 
```

Misc stuff:
- it seems to be against T&C to publish benchmarks: https://stackoverflow.com/a/12116865 🙊

- recommended for sql developer tips:
  - https://www.thatjeffsmith.com/archive/2012/05/getting-started-with-sql-developer-less-than-5-minutes/


### MS SQL Server setup

See details here: https://hub.docker.com/_/microsoft-mssql-server

```
$ podman pull mcr.microsoft.com/mssql/server:2019-latest
$ podman create --name=mssql-xe-container -p 1433:1433 -e "SA_PASSWORD=admin_pass1" -e "ACCEPT_EULA=Y" -e "MSSQL_PID=Express" -v mssql-volume:/var/opt/mssql/data mssql/server:2019-latest
$ podman start -ia mssql-xe-container
```

Este necesar să dăm fiecare privilegiu separat. La fel ca mai sus, dorim să ne
creăm o bază de date separată și un user cu mai puține privilegii.

```sql
SELECT @@version;

CREATE DATABASE test_db;

-- only once
CREATE LOGIN seria35
WITH PASSWORD = 'M$_login1', CHECK_POLICY = OFF;

USE test_db;

-- for each db
CREATE USER seria35
FOR LOGIN seria35;

GRANT EXECUTE TO seria35;
GRANT ALTER ON SCHEMA::dbo TO seria35;
--GRANT CREATE DATABASE TO seria35;
GRANT CREATE TABLE TO seria35;
GRANT REFERENCES TO seria35;
GRANT INSERT TO seria35;
GRANT UPDATE TO seria35;
GRANT SELECT TO seria35;
GRANT DELETE TO seria35;

--GRANT ALL TO seria35; -- deprecated
--REVOKE ALL TO seria35;

-- cleanup
USE master;

DROP USER grupa351;
DROP LOGIN grupa351;
DROP DATABASE test_db;
```

### MariaDB

```
$ podman pull docker.io/mariadb:10.9
$ podman create --name=mariadb-container -p 3306:3306 -e "MARIADB_ROOT_PASSWORD=my-secret-pw" -e "MARIADB_DATABASE=test_db" -e "MARIADB_USER=seria35" -e "MARIADB_PASSWORD=mariadb_pw" -v mariadb-volume:/var/lib/mysql mariadb:10.9
$ podman start -ia mariadb-container
# stop with
$ podman stop mariadb-container
```

```sql
SHOW GRANTS FOR seria35;
GRANT ALL PRIVILEGES ON hr.* TO seria35;
```

Alternative images: https://hub.docker.com/r/yobasystems/alpine-mariadb

### PostgreSQL

```
$ podman pull docker.io/postgres:14.5-alpine
$ podman create --name=postgres-container -p 5432:5432 -e "POSTGRES_PASSWORD=pg-password" -v pg-volume:/var/lib/postgresql/data postgres:14.5-alpine
$ podman start -ia postgres-container
```

Admin:

```sql
CREATE USER seria35 WITH PASSWORD 'Pg=passwd2!';
CREATE DATABASE pbd;
GRANT ALL PRIVILEGES ON DATABASE pbd TO seria35;

-- cleanup
DROP DATABASE pbd;
DROP USER seria35;
```

User:
```sql
select count(*) from employees e ;

--CREATE SCHEMA test_schema;
--SHOW search_path;

SET search_path TO public;
select count(*) from employees e ;
SHOW search_path;
```

