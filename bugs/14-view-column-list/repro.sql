CREATE TABLE t0(c0 INT, c1 INT, c2 INT);
INSERT INTO t0 VALUES (10, 20, 30);
CREATE VIEW v0(c0, c1, c2) AS SELECT c0 + 1, c1 + 1, c2 + 1 FROM t0;

SELECT * FROM v0;
-- 11, 21, 31

SELECT * FROM v0 WHERE c0 = 11;
-- Expected: 11, 21, 31
-- Actual:   empty set

SELECT * FROM v0 WHERE c0 = 31;
-- Expected: empty set
-- Actual:   11, 21, 31
