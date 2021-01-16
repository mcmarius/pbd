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

-->


### Diverse link-uri

- https://stackoverflow.com/questions/49110728/where-current-of-in-pl-sql
- https://docs.oracle.com/cd/E11882_01/server.112/e41084/functions156.htm#SQLRF06100
- todo pentru generat date: https://www.brentozar.com/archive/2016/06/getting-started-with-oracle-generating-test-data/
