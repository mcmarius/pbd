# Proiectarea Bazelor de Date

### Intro

There are a couple of reasons to set up a local DB aside from using the faculty DB:
- admin rights to understand what is happening more exactly
- access to new features
- playground to mess things up
- backup option if faculty DB is down

### Steps:
- setup [`docker`](https://docs.docker.com/engine/install/) and [`docker-compose`](https://docs.docker.com/compose/install/)
- clone this repo: https://github.com/oracle/docker-images/
- navigate inside the repo to `OracleDatabase/SingleInstance/dockerfiles/18.4.0/`
- `docker build -t oracle/database:18.4.0-xe -f Dockerfile.xe .`
- create a file named `docker-compose.yml` with the following contents:
```
version: "3.5" # specify docker-compose version, v3.5 is compatible with docker 17.12.0+

# Define the services/containers to be run
services:
  oracledb:
    image: oracle/database:18.4.0-xe
    environment:
      - ORACLE_PWD=Passw0rd
      # - ORACLE_CHARACTERSET=AL32UTF8 # default is AL32UTF8
    volumes:
      - ./oradata:/opt/oracle/oradata # persistent oracle database data.
    ports:
      - 1521:1521 
      - 8080:8080 # apex
      - 5500:5500 # oemexpress
```
- `mkdir oradata`
- `chmod -R o+w oradata/`
  - this folder needs to have write permissions for other users and groups
    - `-R` means recursive, `o` means other, `+w` means add write rights
  - you might need to change file permissions from within the container (or I just messed things up on my machine)
  - in order to do so:
    - `docker-compose up`
    - in another tab: `docker-compose --file docker-compose.yml exec oracledb sh`
    - inside the container: `chmod -R o+w /opt/oracle/oradata/`
- if something goes wrong:
  - `docker-compose down`
  - `docker-compose up` or `docker-compose up --build` to force a rebuild or if really needed `sudo docker-compose up`
  - remove the `oradata/` directory and restart the previous steps (after creating the `docker-compose` file)
  - see: https://github.com/hantsy/devops-sandbox/blob/master/oracle-database-18.4.0-xe.md
- after a lot of waiting after `docker-compose up`, you should see:
```
oracledb_1  | #########################
oracledb_1  | DATABASE IS READY TO USE!
oracledb_1  | #########################
```
- connect to the database:
  - from shell inside the container
    - `su -p oracle -c "sqlplus / as sysdba"`
    - at the `SQL> ` prompt, `select user from dual;` should be successful
```
USER
--------------------------------------------------------------------------------
SYS
```
  - from SQL Developer:
    - username: `sys` or `SYS` (since sql is case insensitive... at least in this case)
    - **role: `SYSDBA` or `SYSOPER`**
    - password: the one you set up in `docker-compose.yml`
    - port: 1521 (exposed also using the settings provided in `docker-compose.yml`
    - SID: `xe` (stands for express edition)

:warning: Warning! We will not use this user on an every day basis. Instead, we need to create users with limited privileges so they are not able to blow up the whole system :boom:

### Creating users

Work in progress.

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

- recommended for sql developer tips:
  - https://www.thatjeffsmith.com/archive/2012/05/getting-started-with-sql-developer-less-than-5-minutes/

