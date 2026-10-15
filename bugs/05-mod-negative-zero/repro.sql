SELECT -5 MOD 5, 5 MOD 5;
-- Expected: 0, 0
-- Actual:   -0, 0

SELECT COUNT(DISTINCT m) FROM (SELECT -5 MOD 5 AS m UNION ALL SELECT 5 MOD 5) t;
-- Expected: 1
-- Actual:   2

CREATE TABLE t0(c0 INT);
CREATE TABLE t1(c0 INT);
INSERT INTO t0 VALUES (-4), (-2), (5);
INSERT INTO t1 VALUES (3), (4), (6), (7), (8), (9), (10), (11);

SELECT SUM((t0.c0 MOD 2) = (t1.c0 MOD 2)) FROM t0, t1;
-- 12

SELECT COUNT(*) FROM t0 JOIN t1 ON (t0.c0 MOD 2) = (t1.c0 MOD 2);
-- Expected: 12
-- Actual:   4
