# Unexpected results of a multi-word MATCH ... AGAINST: a row is returned twice

**Affected:** Every tested release (1.78.0 through 2.4.2) and master.

## What happens

`MATCH(c1, c2) AGAINST ('abc def')` is positive for rows 1 and 2, but the `WHERE` returns row 1 twice. A single-word search returns each row once.

## Test case

Run in a fresh database ([repro.sql](repro.sql)):

```sql
CREATE TABLE t0(c0 INT PRIMARY KEY, c1 TEXT, c2 TEXT, FULLTEXT ft0(c1, c2));
INSERT INTO t0 VALUES (1, 'abc def', 'ghi jkl'), (2, 'abc', 'mno'), (3, 'xyz', 'pqr');

SELECT c0, MATCH(c1, c2) AGAINST ('abc def') > 0 AS p FROM t0 ORDER BY c0;
-- 1, 1 / 2, 1 / 3, 0

SELECT c0 FROM t0 WHERE MATCH(c1, c2) AGAINST ('abc def') ORDER BY c0;
-- Expected: 1 / 2
-- Actual:   1 / 1 / 2
```

Verified through the MySQL protocol on Dolt 2.4.2 and master `ce68e18` (2026-10-14). MySQL 8.4.6 returns the expected results.
