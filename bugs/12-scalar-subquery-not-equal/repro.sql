CREATE TABLE t0(c0 INT);
CREATE TABLE t1(c0 INT);
INSERT INTO t1 VALUES (1);

SELECT c0, c0 <> (SELECT c0 FROM t0) AS p FROM t1;
-- 1, NULL

SELECT * FROM t1 WHERE c0 <> (SELECT c0 FROM t0);
-- Expected: empty set
-- Actual:   1

INSERT INTO t0 VALUES (2), (3);

SELECT * FROM t1 WHERE c0 <> (SELECT c0 FROM t0);
-- Expected: ERROR 1242 (21000): Subquery returns more than 1 row
-- Actual:   1
