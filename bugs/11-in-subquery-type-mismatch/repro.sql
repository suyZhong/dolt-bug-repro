SELECT false NOT IN (SELECT 'W1q'), false NOT IN ('W1q');
-- Expected: 0, 0
-- Actual:   1, 0

SELECT false IN (SELECT 'W1q'), false IN ('W1q');
-- Expected: 1, 1
-- Actual:   0, 1

CREATE TABLE t0(c0 INT);
INSERT INTO t0 VALUES (2), (NULL);

SELECT 'a' IN (SELECT c0 FROM t0), 'a' IN (2, NULL);
-- Expected: NULL, NULL
-- Actual:   0, NULL

SELECT 'a' NOT IN (SELECT c0 FROM t0), 'a' NOT IN (2, NULL);
-- Expected: NULL, NULL
-- Actual:   1, NULL
