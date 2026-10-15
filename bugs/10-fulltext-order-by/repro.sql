CREATE TABLE t0(c0 INT, c1 VARCHAR(100));
CREATE FULLTEXT INDEX ft0 ON t0(c1);
INSERT INTO t0 VALUES (1, 'b'), (2, 'a');

SELECT * FROM t0 ORDER BY c0;
-- 1, b / 2, a

SELECT * FROM t0 ORDER BY c1;
-- Expected: 2, a / 1, b
-- Actual:   empty set
