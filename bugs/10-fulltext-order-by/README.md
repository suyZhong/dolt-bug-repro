# Unexpected results when ordering by a column that has a FULLTEXT index

**Affected:** Every tested release (1.78.0 through 2.4.2) and master.

## What happens

`SELECT * FROM t0 ORDER BY c1` returns no rows when `c1` has a FULLTEXT index. `EXPLAIN PLAN` shows `IndexedTableAccess(t0)` on index `[t0.c1]`, so the FULLTEXT index is read as a sorted index. Ordering by another column returns both rows.

## Test case

Run in a fresh database ([repro.sql](repro.sql)):

```sql
CREATE TABLE t0(c0 INT, c1 VARCHAR(100));
CREATE FULLTEXT INDEX ft0 ON t0(c1);
INSERT INTO t0 VALUES (1, 'b'), (2, 'a');

SELECT * FROM t0 ORDER BY c0;
-- 1, b / 2, a

SELECT * FROM t0 ORDER BY c1;
-- Expected: 2, a / 1, b
-- Actual:   empty set
```

Verified through the MySQL protocol on Dolt 2.4.2 and master `ce68e18` (2026-10-14). MySQL 8.4.6 returns the expected results.
