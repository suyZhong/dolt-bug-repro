SELECT (CAST(NULL AS DATETIME), 5) <=> (1, 5), (NULL, 5) <=> (1, 5), CAST(NULL AS DATETIME) <=> 1;
-- Expected: 0, 0, 0
-- Actual:   1, 0, 0

CREATE TABLE t0(c0 INT, c1 TIMESTAMP);
INSERT INTO t0 VALUES (5, NULL);

SELECT COUNT(*) FROM t0 WHERE (1, c0) <=> (c1, c0);
-- Expected: 0
-- Actual:   1
