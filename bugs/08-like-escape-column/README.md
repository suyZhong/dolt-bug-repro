# Internal error with LIKE ... ESCAPE <column> under UNION ALL

**Affected:** Every tested release (1.78.0 through 2.4.2) and master.

## What happens

MySQL rejects the column-valued `ESCAPE` argument with `Incorrect arguments to ESCAPE`. Dolt accepts it: the single query returns an empty set, while the `UNION ALL` form raises `unable to find field with index 3 in row of 2 columns. This is a bug.`

## Test case

Run in a fresh database ([repro.sql](repro.sql)):

```sql
CREATE TABLE t0(c0 INT, c1 INT);
INSERT INTO t0 VALUES (1, 5), (2, 0), (3, NULL), (NULL, 7);

SELECT * FROM t0 WHERE c1 LIKE c0 ESCAPE c0;
-- Expected: ERROR 1210 (HY000): Incorrect arguments to ESCAPE (as in MySQL), or a result
-- Actual:   empty set

SELECT * FROM t0 WHERE c1 LIKE c0 ESCAPE c0 UNION ALL SELECT * FROM t0 WHERE NOT (c1 LIKE c0 ESCAPE c0);
-- Expected: ERROR 1210 (HY000): Incorrect arguments to ESCAPE (as in MySQL), or a result
-- Actual:   ERROR 1105 (HY000): unable to find field with index 3 in row of 2 columns. This is a bug. Please file an issue here: https://github.com/dolthub/dolt/issues
```

Verified through the MySQL protocol on Dolt 2.4.2 and master `ce68e18` (2026-10-14). MySQL 8.4.6 rejects the column-valued `ESCAPE` argument.
