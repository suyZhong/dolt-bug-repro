CREATE TABLE t0(a INT);
INSERT INTO t0 VALUES (1000), (2), (NULL);

SELECT * FROM t0 WHERE COALESCE(1.5, a) > 1;
-- 1000 / 2 / NULL (any order)

SELECT * FROM t0 WHERE COALESCE(a, 1.5) > 1;
-- Expected: 1000 / 2 / NULL (any order)
-- Actual:   ERROR 1105 (HY000): Out of range value for column of Decimal type

SELECT a, COALESCE(a, 1.5) FROM t0;
-- Expected: 1000, 1000.0 / 2, 2.0 / NULL, 1.5 (any order)
-- Actual:   ERROR 1105 (HY000): Out of range value for column of Decimal type
