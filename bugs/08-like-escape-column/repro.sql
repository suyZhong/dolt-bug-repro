CREATE TABLE t0(c0 INT, c1 INT);
INSERT INTO t0 VALUES (1, 5), (2, 0), (3, NULL), (NULL, 7);

SELECT * FROM t0 WHERE c1 LIKE c0 ESCAPE c0;
-- Expected: ERROR 1210 (HY000): Incorrect arguments to ESCAPE (as in MySQL), or a result
-- Actual:   empty set

SELECT * FROM t0 WHERE c1 LIKE c0 ESCAPE c0 UNION ALL SELECT * FROM t0 WHERE NOT (c1 LIKE c0 ESCAPE c0);
-- Expected: ERROR 1210 (HY000): Incorrect arguments to ESCAPE (as in MySQL), or a result
-- Actual:   ERROR 1105 (HY000): unable to find field with index 3 in row of 2 columns. This is a bug. Please file an issue here: https://github.com/dolthub/dolt/issues
