# Unexpected results when filtering a join of two tables and a view on a predicate over all three

**Affected:** The first form returns a wrong count from 2.3.0 through 2.4.2 and on master. The second form returns a wrong empty result in 2.1.0 and earlier, and raises an internal error from 2.3.0.

## What happens

The first query filters a comma join of `t0`, `t1` and the view `v2` with `(x = y) OR (v2.z <> 1)`. It returns 2 rows, but the predicate is true for 5. `EXPLAIN PLAN` shows the predicate placed on an `InnerJoin` of `t0` and `t1` only, under a `HashLookup` with empty keys, while `v2` sits on the other side of a `CrossHashJoin`.

The second form has a similar shape and raises `unable to find field with index 7 in row of 4 columns. This is a bug.` Releases through 2.1.0 return the expected count for the first form but a wrong empty result for the second.

## Test case

Run in a fresh database ([repro.sql](repro.sql)):

```sql
CREATE TABLE t0(x INT);
INSERT INTO t0 VALUES (1), (2);
CREATE TABLE t1(y INT);
INSERT INTO t1 VALUES (1), (NULL);
CREATE TABLE t2(z INT);
INSERT INTO t2 VALUES (1), (0);
CREATE VIEW v2 AS SELECT z FROM t2;

SELECT SUM((x = y) OR (v2.z <> 1)) FROM t0, t1, v2;
-- 5

SELECT COUNT(*) FROM t0, t1, v2 WHERE (x = y) OR (v2.z <> 1);
-- Expected: 5
-- Actual:   2

CREATE TABLE a(c0 BOOLEAN PRIMARY KEY, c1 INT);
CREATE TABLE b(c0 INT, c1 BOOLEAN, c2 BOOLEAN, PRIMARY KEY(c0, c1));
INSERT INTO b VALUES (1, false, false), (2, true, true), (3, false, NULL), (4, true, NULL);
INSERT INTO a VALUES (true, 1), (false, NULL);
CREATE VIEW va(c0) AS SELECT a.c1 FROM a;

SELECT SUM((va.c0 = b.c0) <= (CASE WHEN a.c0 THEN b.c2 END)) FROM va, b, a;
-- 1

SELECT * FROM va, b, a WHERE (va.c0 = b.c0) <= (CASE WHEN a.c0 THEN b.c2 END);
-- Expected: 1, 2, 1, 1, 1, 1
-- Actual:   ERROR 1105 (HY000): unable to find field with index 7 in row of 4 columns. This is a bug. Please file an issue here: https://github.com/dolthub/dolt/issues
```

Verified through the MySQL protocol on Dolt 2.4.2 and master `ce68e18` (2026-10-14). MySQL 8.4.6 returns the expected results.
