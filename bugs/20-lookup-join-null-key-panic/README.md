# Lost connection on a LEFT JOIN ON key = NULL executed as a lookup join

**Affected:** Every tested release (1.78.0 through 2.4.2) and master.

## What happens

`t1 LEFT JOIN t0 ON t0.c0 = NULL` should return `t1`'s row extended with NULL. Without a hint, it does. With the plan forced to a lookup join, the server panics and closes the connection. The server log shows `cannot write NULL to non-NULL field` from kvexec `newLookupKeyMapping`. The planner also picks this plan on its own on larger tables (for example 100 rows after `ANALYZE TABLE`). The hint just makes the repro small.

## Test case

Run in a fresh database ([repro.sql](repro.sql)):

```sql
CREATE TABLE t0(c0 INT PRIMARY KEY);
INSERT INTO t0 VALUES (1), (2), (3);
CREATE TABLE t1(c0 INT);
INSERT INTO t1 VALUES (1);

SELECT * FROM t1 LEFT JOIN t0 ON t0.c0 = NULL;
-- 1, NULL

SELECT /*+ LOOKUP_JOIN(t1,t0) */ * FROM t1 LEFT JOIN t0 ON t0.c0 = NULL;
-- Expected: 1, NULL
-- Actual:   ERROR 2013 (HY000): Lost connection to MySQL server during query
```

Verified through the MySQL protocol on Dolt 2.4.2 and master `ce68e18` (2026-10-14). MySQL 8.4.6 returns the expected results.
