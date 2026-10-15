CREATE TABLE t0(c0 INT PRIMARY KEY, c1 TEXT, c2 TEXT, FULLTEXT ft0(c1, c2));
INSERT INTO t0 VALUES (1, 'abc def', 'ghi jkl'), (2, 'abc', 'mno'), (3, 'xyz', 'pqr');

SELECT c0, MATCH(c1, c2) AGAINST ('abc def') > 0 AS p FROM t0 ORDER BY c0;
-- 1, 1 / 2, 1 / 3, 0

SELECT c0 FROM t0 WHERE MATCH(c1, c2) AGAINST ('abc def') ORDER BY c0;
-- Expected: 1 / 2
-- Actual:   1 / 1 / 2
