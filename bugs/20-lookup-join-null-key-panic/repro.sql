CREATE TABLE t0(c0 INT PRIMARY KEY);
INSERT INTO t0 VALUES (1), (2), (3);
CREATE TABLE t1(c0 INT);
INSERT INTO t1 VALUES (1);

SELECT * FROM t1 LEFT JOIN t0 ON t0.c0 = NULL;
-- 1, NULL

SELECT /*+ LOOKUP_JOIN(t1,t0) */ * FROM t1 LEFT JOIN t0 ON t0.c0 = NULL;
-- Expected: 1, NULL
-- Actual:   ERROR 2013 (HY000): Lost connection to MySQL server during query
