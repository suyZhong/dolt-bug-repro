CREATE TABLE t0(x INT);
INSERT INTO t0 VALUES (1), (2);
CREATE TABLE t1(y INT);
INSERT INTO t1 VALUES (1), (NULL);
CREATE TABLE t2(z INT);
INSERT INTO t2 VALUES (1), (0);
CREATE VIEW v2 AS SELECT z FROM t2;

SELECT SUM((x = y) OR (v2.z <> 1)) FROM t0, t1, v2;
-- 5

SELECT COUNT(*) FROM t0, t1, v2 WHERE (x = y) OR (v2.z <> 1);
-- Expected: 5
-- Actual:   2

CREATE TABLE a(c0 BOOLEAN PRIMARY KEY, c1 INT);
CREATE TABLE b(c0 INT, c1 BOOLEAN, c2 BOOLEAN, PRIMARY KEY(c0, c1));
INSERT INTO b VALUES (1, false, false), (2, true, true), (3, false, NULL), (4, true, NULL);
INSERT INTO a VALUES (true, 1), (false, NULL);
CREATE VIEW va(c0) AS SELECT a.c1 FROM a;

SELECT SUM((va.c0 = b.c0) <= (CASE WHEN a.c0 THEN b.c2 END)) FROM va, b, a;
-- 1

SELECT * FROM va, b, a WHERE (va.c0 = b.c0) <= (CASE WHEN a.c0 THEN b.c2 END);
-- Expected: 1, 2, 1, 1, 1, 1
-- Actual:   ERROR 1105 (HY000): unable to find field with index 7 in row of 4 columns. This is a bug. Please file an issue here: https://github.com/dolthub/dolt/issues
