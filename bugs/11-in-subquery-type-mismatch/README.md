# Unexpected results of IN (SELECT ...) when the operand types differ

**Affected:** Every tested release (1.78.0 through 2.4.2) and master.

## What happens

With a subquery on the right, `IN` / `NOT IN` give a different answer from the same value list written out:

- `false IN (SELECT 'W1q')` is 0, but `false IN ('W1q')` is 1 (`'W1q'` converts to 0).
- `'a' IN (SELECT c0 FROM t0)` over an INT column holding `2, NULL` is 0, but `'a' IN (2, NULL)` is NULL. `NOT IN` gives 1 instead of NULL.

In a `WHERE` clause the planner usually rewrites these to a semi-join, which is correct. The wrong value appears in the select list and in `UNION ALL` branches.

## Test case

Run in a fresh database ([repro.sql](repro.sql)):

```sql
SELECT false NOT IN (SELECT 'W1q'), false NOT IN ('W1q');
-- Expected: 0, 0
-- Actual:   1, 0

SELECT false IN (SELECT 'W1q'), false IN ('W1q');
-- Expected: 1, 1
-- Actual:   0, 1

CREATE TABLE t0(c0 INT);
INSERT INTO t0 VALUES (2), (NULL);

SELECT 'a' IN (SELECT c0 FROM t0), 'a' IN (2, NULL);
-- Expected: NULL, NULL
-- Actual:   0, NULL

SELECT 'a' NOT IN (SELECT c0 FROM t0), 'a' NOT IN (2, NULL);
-- Expected: NULL, NULL
-- Actual:   1, NULL
```

Verified through the MySQL protocol on Dolt 2.4.2 and master `ce68e18` (2026-10-14). MySQL 8.4.6 returns the expected results.
