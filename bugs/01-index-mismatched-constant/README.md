# Indexed comparisons return rows inconsistent with the predicate value

**Affected:** Every tested release (1.78.0 through 2.4.2) and master; some forms only in newer releases, as noted below.

## What happens

Each pair compares a primary-key column with a constant. The first query evaluates the predicate in the select list; the second uses it as a filter and returns an inconsistent result:

- INT key, `c0 <> '1.5'`: the predicate is 1 for both rows, but the row `c0 = 1` is dropped. `EXPLAIN PLAN` shows the index range `{(NULL, 1)}, {(1, ∞)}`, consistent with converting `'1.5'` to `1` when building the range.
- FLOAT key, `c0 <> CAST(... AS FLOAT)`: the predicate is 0, but the row is returned.
- TIMESTAMP key, `c0 > '1969-12-18 02:32:34'`: the predicate is 1, but no row is returned. Releases before 2.3.5 raise `value "1969-12-18 02:32:34" is outside of timestamp range` instead.
- TIME key, `c0 <> 2411793`: the predicate is 1, but no row is returned. This form is correct on 2.4.0 and wrong from 2.4.2.

Without the index, every filter returns the rows the select list predicts.

## Test case

Run in a fresh database ([repro.sql](repro.sql)):

```sql
CREATE TABLE t0(c0 INT PRIMARY KEY);
INSERT INTO t0 VALUES (1), (2);

SELECT c0, c0 <> '1.5' AS p FROM t0 ORDER BY c0;
-- 1, 1 / 2, 1

SELECT c0 FROM t0 WHERE c0 <> '1.5' ORDER BY c0;
-- Expected: 1 / 2
-- Actual:   2

CREATE TABLE t1(c0 FLOAT PRIMARY KEY);
INSERT INTO t1 VALUES (0.89451053545548);

SELECT c0 <> CAST(0.89451053545548 AS FLOAT) AS p FROM t1;
-- 0

SELECT COUNT(*) FROM t1 WHERE c0 <> CAST(0.89451053545548 AS FLOAT);
-- Expected: 0
-- Actual:   1

CREATE TABLE t2(c0 TIMESTAMP PRIMARY KEY);
INSERT INTO t2 VALUES ('1970-01-23 10:07:51');

SELECT c0, c0 > '1969-12-18 02:32:34' AS p FROM t2;
-- 1970-01-23 10:07:51, 1

SELECT * FROM t2 WHERE c0 > '1969-12-18 02:32:34';
-- Expected: 1970-01-23 10:07:51
-- Actual:   empty set

CREATE TABLE t3(c0 TIME PRIMARY KEY);
INSERT INTO t3 VALUES ('12:00:00');

SELECT c0 <> 2411793 AS p FROM t3;
-- 1

SELECT COUNT(*) FROM t3 WHERE c0 <> 2411793;
-- Expected: 1
-- Actual:   0
```

Verified through the MySQL protocol on Dolt 2.4.2 and master `ce68e18` (2026-10-14). MySQL 8.4.6 returns the expected results.
