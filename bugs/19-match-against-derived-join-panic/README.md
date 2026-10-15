# Lost connection when MATCH ... AGAINST is used over a derived table or in a JOIN ON clause

**Affected:** Every tested release (1.78.0 through 2.4.2) and master.

## What happens

`MATCH ... AGAINST` works on the base table, but using it over a derived-table column or in a `JOIN ... ON` clause closes the connection. The server log shows a recovered panic in planbuilder `buildMatchAgainst` (`shouldn't be able to resolve expression without table being available`); the server keeps running. MySQL returns rows for both queries. The fixed dolthub/dolt#10729 covers a different `MATCH`-in-join test case that works on master.


Each panicking query closes the connection, and the `mysql` client in batch mode does not reconnect. Run the two failing queries one at a time.

## Test case

Run in a fresh database ([repro.sql](repro.sql)):

```sql
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
```

Verified through the MySQL protocol on Dolt 2.4.2 and master `ce68e18` (2026-10-14). MySQL 8.4.6 returns the expected results.
