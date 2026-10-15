CREATE TABLE t0(c0 INT PRIMARY KEY, c1 TEXT, c2 TEXT, FULLTEXT ft0(c1, c2));
INSERT INTO t0 VALUES (1, 'abc def', 'ghi jkl'), (2, 'abc', 'mno');
CREATE TABLE t1(x INT);
INSERT INTO t1 VALUES (1);

SELECT c0 FROM t0 WHERE MATCH(c1, c2) AGAINST ('abc') ORDER BY c0;
-- 1 / 2

SELECT * FROM (SELECT c1, c2 FROM t0) d WHERE MATCH(d.c1, d.c2) AGAINST ('abc');
-- Expected: abc def, ghi jkl / abc, mno (as in MySQL), or an error
-- Actual:   ERROR 2013 (HY000): Lost connection to MySQL server during query

SELECT * FROM t0 JOIN t1 ON MATCH(t0.c1, t0.c2) AGAINST ('abc');
-- Expected: 1, abc def, ghi jkl, 1 / 2, abc, mno, 1 (as in MySQL), or an error
-- Actual:   ERROR 2013 (HY000): Lost connection to MySQL server during query
