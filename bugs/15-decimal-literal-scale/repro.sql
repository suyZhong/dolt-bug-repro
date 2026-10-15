CREATE TABLE t0(c0 DECIMAL(10,2));
INSERT INTO t0 VALUES (1.00);

SELECT c0, c0 = 1.001, 1.00 = 1.001 FROM t0;
-- Expected: 1.00, 0, 0
-- Actual:   1.00, 1, 0

SELECT * FROM t0 WHERE c0 = 1.001;
-- Expected: empty set
-- Actual:   1.00

SELECT CAST(2 AS DECIMAL(20,0)) > 1.5, 2 > 1.5;
-- Expected: 1, 1
-- Actual:   0, 1
