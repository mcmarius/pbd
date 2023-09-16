### Q&A

**Q: `binary_integer` sau `pls_integer`?**

A: În versiunile actuale e același lucru (documentații: [11g](https://docs.oracle.com/cd/E11882_01/appdev.112/e25519/datatypes.htm#LNPLS319), [12c](https://docs.oracle.com/database/121/LNPLS/datatypes.htm#LNPLS99938)).

**Q: Tablouri imbricate sau indexate?**

A:

Imbricate:
- pot fi folosite în SQL

Indexate:
- nu necesită extinderea automată a capacității interne, pot avea indici negativi

**Q: O funcție poate întoarce un cursor?**

A: [Da.](https://stackoverflow.com/questions/25891044/returning-a-ref-cursor-from-a-oracle-function)

-----

TIL se poate folosi `cursor%rowtype`.

`update from`

funcții analitice

-----

<!--

TODO
De exportat tabelele din schema HR în csv, apoi de portat manual 😢 script-urile pt constrângeri și mai știu eu ce

https://gist.github.com/gourab5139014/b0b8e90c66acd5d0e9bcfebbff65d02a
https://github.com/nomemory/neat-sample-databases-generators
https://github.com/nomemory/hr-schema-mysql
https://github.com/andriimazur93/hr_schema_sql_server

alternativ, dar mai puține date: https://www.sqltutorial.org/sql-sample-database/

-->


### Diverse link-uri

- https://nils85.github.io/sql-compat-table/index.html
- https://use-the-index-luke.com/
- https://stackoverflow.com/questions/49110728/where-current-of-in-pl-sql
- https://docs.oracle.com/cd/E11882_01/server.112/e41084/functions156.htm#SQLRF06100
- todo pentru generat date: https://www.brentozar.com/archive/2016/06/getting-started-with-oracle-generating-test-data/


DBs:
- relaționale:
  - [Oracle](https://www.oracletutorial.com/)
  - [PostgreSQL](https://www.postgresqltutorial.com/)
  - [MySQL](https://www.mysqltutorial.org/)/[MariaDB](https://www.mariadbtutorial.com/)
  - [SQL Server](https://www.sqlservertutorial.net)
  - [SQLite](https://www.sqlitetutorial.net/)
- tip document:
  - [MongoDB](https://www.mongodbtutorial.org/)
  - [DynamoDB](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/DynamoDBLocal.html)
  - ScyllaDB
- time series:
  - InfluxDB
  - Prometheus/Victoria Metrics
- caching:
  - Redis
  - [Dragonfly](https://github.com/dragonflydb/dragonfly): alternativă la Redis/Memcached

Misc:
- https://docs.oracle.com/cd/B10500_01/appdev.920/a96624/07_errs.htm#784
- https://docs.oracle.com/cd/B28359_01/server.111/b28278/toc.htm
- https://news.ycombinator.com/item?id=18442637
- https://danieltemkin.com/Esolangs/Folders/
- https://en.wikipedia.org/wiki/Copy-on-write
