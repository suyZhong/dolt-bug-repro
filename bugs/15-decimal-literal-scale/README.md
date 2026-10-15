# Unexpected results when comparing a DECIMAL with a literal that has more decimal places

**Affected:** Every tested release (1.78.0 through 2.4.2) and master; some forms only in newer releases, as noted below.

## What happens

`DECIMAL(10,2)` value `1.00` compares equal to `1.001`, in the select list and in `WHERE`. `1.00 = 1.001` between two literals is correct. A related form, `CAST(2 AS DECIMAL(20,0)) > 1.5`, returns 0; this one is correct up to 2.3.5 and wrong from 2.4.0.

## Test case

Run in a fresh database ([repro.sql](repro.sql)):

```sql
CREATE TABLE t0(c0 DECIMAL(10,2));
INSERT INTO t0 VALUES (1.00);

SELECT c0, c0 = 1.001, 1.00 = 1.001 FROM t0;
-- Expected: 1.00, 0, 0
-- Actual:   1.00, 1, 0

SELECT * FROM t0 WHERE c0 = 1.001;
-- Expected: empty set
-- Actual:   1.00

SELECT CAST(2 AS DECIMAL(20,0)) > 1.5, 2 > 1.5;
-- Expected: 1, 1
-- Actual:   0, 1
```

Verified through the MySQL protocol on Dolt 2.4.2 and master `ce68e18` (2026-10-14). MySQL 8.4.6 returns the expected results.
