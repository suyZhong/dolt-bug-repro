# Unexpected results of <=> between rows when one row holds a NULL DATETIME/TIMESTAMP

**Affected:** 2.3.0 through 2.4.2, and master.

## What happens

`(CAST(NULL AS DATETIME), 5) <=> (1, 5)` returns 1. A NULL `DATETIME`/`TIMESTAMP` field compares as equal to a non-NULL value inside a row comparison, while `(NULL, 5) <=> (1, 5)` and `CAST(NULL AS DATETIME) <=> 1` are correctly 0. The same happens for a `TIMESTAMP` column holding NULL. Releases before 2.3.0 raise `Incorrect datetime value: '1'` instead. The closed #11024 looks related.

## Test case

Run in a fresh database ([repro.sql](repro.sql)):

```sql
SELECT (CAST(NULL AS DATETIME), 5) <=> (1, 5), (NULL, 5) <=> (1, 5), CAST(NULL AS DATETIME) <=> 1;
-- Expected: 0, 0, 0
-- Actual:   1, 0, 0

CREATE TABLE t0(c0 INT, c1 TIMESTAMP);
INSERT INTO t0 VALUES (5, NULL);

SELECT COUNT(*) FROM t0 WHERE (1, c0) <=> (c1, c0);
-- Expected: 0
-- Actual:   1
```

Verified through the MySQL protocol on Dolt 2.4.2 and master `ce68e18` (2026-10-14). MySQL 8.4.6 returns the expected results.
