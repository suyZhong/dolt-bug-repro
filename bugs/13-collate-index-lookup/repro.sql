CREATE TABLE t0(s VARCHAR(20) COLLATE utf8mb4_bin PRIMARY KEY);
INSERT INTO t0 VALUES ('a'), ('B');

SELECT s, s = ('A' COLLATE utf8mb4_general_ci) AS p FROM t0 ORDER BY s;
-- B, 0 / a, 1

SELECT * FROM t0 WHERE s = ('A' COLLATE utf8mb4_general_ci);
-- Expected: a
-- Actual:   empty set

CREATE TABLE t1(s VARCHAR(20) COLLATE utf8mb4_bin);
INSERT INTO t1 VALUES ('a'), ('B');

SELECT * FROM t1 WHERE s = ('A' COLLATE utf8mb4_general_ci);
-- a
