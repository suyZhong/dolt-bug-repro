# Unexpected results when an explicit COLLATE is compared with an indexed column

**Affected:** Every tested release (1.78.0 through 2.4.2) and master.

## What happens

The `utf8mb4_bin` primary key holds `'a'` and `'B'`. `s = ('A' COLLATE utf8mb4_general_ci)` is 1 for `'a'` in the select list, but the `WHERE` returns nothing. The same table without the key returns `'a'`.

## Test case

Run in a fresh database ([repro.sql](repro.sql)):

```sql
CREATE TABLE t0(s VARCHAR(20) COLLATE utf8mb4_bin PRIMARY KEY);
INSERT INTO t0 VALUES ('a'), ('B');

SELECT s, s = ('A' COLLATE utf8mb4_general_ci) AS p FROM t0 ORDER BY s;
-- B, 0 / a, 1

SELECT * FROM t0 WHERE s = ('A' COLLATE utf8mb4_general_ci);
-- Expected: a
-- Actual:   empty set

CREATE TABLE t1(s VARCHAR(20) COLLATE utf8mb4_bin);
INSERT INTO t1 VALUES ('a'), ('B');

SELECT * FROM t1 WHERE s = ('A' COLLATE utf8mb4_general_ci);
-- a
```

Verified through the MySQL protocol on Dolt 2.4.2 and master `ce68e18` (2026-10-14). MySQL 8.4.6 returns the expected results.
