CREATE TABLE a(x BOOLEAN);
INSERT INTO a VALUES (0);
CREATE TABLE b(y BOOLEAN);
INSERT INTO b VALUES (1);
CREATE TABLE e(z BOOLEAN);

SELECT a.x, b.y, e.z, (a.x < b.y) AND (a.x < e.z) AS p FROM a, b LEFT JOIN e ON (1 = 0);
-- 0, 1, NULL, NULL

SELECT * FROM a, b LEFT JOIN e ON (1 = 0) WHERE (a.x < b.y) AND (a.x < e.z);
-- Expected: empty set
-- Actual:   0, 1, NULL

SELECT * FROM a, b LEFT JOIN e ON (1 = 0) WHERE a.x < e.z;
-- empty set

SELECT * FROM a, b LEFT JOIN e ON (1 = 0) WHERE ((a.x < b.y) AND (a.x < e.z)) IS NULL;
-- Expected: 0, 1, NULL
-- Actual:   ERROR 1105 (HY000): unable to find field with index 3 in row of 2 columns. This is a bug. Please file an issue here: https://github.com/dolthub/dolt/issues
