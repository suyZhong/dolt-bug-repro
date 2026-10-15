# Unexpected results when filtering with <> against a scalar subquery

**Affected:** Every tested release (1.78.0 through 2.4.2) and master.

## What happens

With an empty subquery, `c0 <> (SELECT c0 FROM t0)` is NULL, as the select list shows, but the `WHERE` returns the row. With a multi-row subquery, Dolt returns the row instead of raising `Subquery returns more than 1 row`. `EXPLAIN PLAN` shows the comparison rewritten to `LeftOuterJoinExcludingNulls` with a `1 IS NULL` filter.

## Test case

Run in a fresh database ([repro.sql](repro.sql)):

```sql
CREATE TABLE t0(c0 INT);
CREATE TABLE t1(c0 INT);
INSERT INTO t1 VALUES (1);

SELECT c0, c0 <> (SELECT c0 FROM t0) AS p FROM t1;
-- 1, NULL

SELECT * FROM t1 WHERE c0 <> (SELECT c0 FROM t0);
-- Expected: empty set
-- Actual:   1

INSERT INTO t0 VALUES (2), (3);

SELECT * FROM t1 WHERE c0 <> (SELECT c0 FROM t0);
-- Expected: ERROR 1242 (21000): Subquery returns more than 1 row
-- Actual:   1
```

Verified through the MySQL protocol on Dolt 2.4.2 and master `ce68e18` (2026-10-14). MySQL 8.4.6 returns the expected results.
