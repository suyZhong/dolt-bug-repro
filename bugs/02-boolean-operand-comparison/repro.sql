CREATE TABLE t0(c0 INT);
INSERT INTO t0 VALUES (0), (1), (2), (5);

SELECT c0, (1 > 0) < c0 AS p FROM t0;
-- 0, 0 / 1, 0 / 2, 1 / 5, 1 (any order)

SELECT c0 FROM t0 WHERE (1 > 0) < c0;
-- Expected: 2 / 5 (any order)
-- Actual:   empty set

SELECT c0 FROM t0 WHERE NOT ((1 > 0) < c0);
-- Expected: 0 / 1 (any order)
-- Actual:   empty set

SELECT c0 FROM t0 WHERE (1 > 0) < c0 ORDER BY c0;
-- 2 / 5

SELECT c0 FROM t0 WHERE (c0 >= 1) > false;
-- Expected: 1 / 2 / 5 (any order)
-- Actual:   empty set
