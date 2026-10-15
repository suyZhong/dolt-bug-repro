CREATE TABLE t0(a INT PRIMARY KEY, w INT);
INSERT INTO t0 VALUES (1, 0), (2, 1);
CREATE TABLE t1(lo INT, hi INT);
INSERT INTO t1 VALUES (0, 10);

SELECT t0.a, t0.w FROM t0 JOIN t1 ON t0.a BETWEEN t1.lo AND t1.hi WHERE t0.w = 1;
-- Expected: 2, 1
-- Actual:   1, 0 / 2, 1

SELECT t0.a, t0.w FROM t0 JOIN t1 ON t0.a >= t1.lo WHERE t0.w = 1;
-- 2, 1
