# Unexpected results when filtering on AND with a column from the NULL-extended side of a LEFT JOIN

**Affected:** Every tested release (1.78.0 through 2.4.2) and master; some forms only in newer releases, as noted below.

## What happens

`(a.x < b.y) AND (a.x < e.z)` is NULL for the only row, because `e.z` comes from the null-extended side of the LEFT JOIN. The `WHERE` still returns that row, while `WHERE a.x < e.z` alone correctly returns nothing. The `IS NULL` form, which should return the row, fails with `unable to find field with index 3 in row of 2 columns. This is a bug.` from 1.84.0 on; 1.78.0 returns the row.

## Test case

Run in a fresh database ([repro.sql](repro.sql)):

```sql
CREATE TABLE a(x BOOLEAN);
INSERT INTO a VALUES (0);
CREATE TABLE b(y BOOLEAN);
INSERT INTO b VALUES (1);
CREATE TABLE e(z BOOLEAN);

SELECT a.x, b.y, e.z, (a.x < b.y) AND (a.x < e.z) AS p FROM a, b LEFT JOIN e ON (1 = 0);
-- 0, 1, NULL, NULL

SELECT * FROM a, b LEFT JOIN e ON (1 = 0) WHERE (a.x < b.y) AND (a.x < e.z);
-- Expected: empty set
-- Actual:   0, 1, NULL

SELECT * FROM a, b LEFT JOIN e ON (1 = 0) WHERE a.x < e.z;
-- empty set

SELECT * FROM a, b LEFT JOIN e ON (1 = 0) WHERE ((a.x < b.y) AND (a.x < e.z)) IS NULL;
-- Expected: 0, 1, NULL
-- Actual:   ERROR 1105 (HY000): unable to find field with index 3 in row of 2 columns. This is a bug. Please file an issue here: https://github.com/dolthub/dolt/issues
```

Verified through the MySQL protocol on Dolt 2.4.2 and master `ce68e18` (2026-10-14). MySQL 8.4.6 returns the expected results.
