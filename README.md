# Dolt bug reproductions

This repository collects 23 Dolt test cases found by automated SQL testing: 15 show unexpected results (two also raise an internal error), 3 raise unexpected errors, and 5 trigger panics or dropped connections. Each case has a short report and a standalone `repro.sql`. The table below indexes the cases, which can be tracked separately if useful. The 23 cases do not necessarily represent 23 independent root causes.

*The cases were found by a fuzzer and triaged with the help of an automated agent. Every test case was rerun manually. The `EXPLAIN PLAN` observations describe the observed plans; they do not establish a root cause.*

| # | Summary | Affected releases |
| --- | --- | --- |
| [01](bugs/01-index-mismatched-constant/) | Indexed comparisons return rows inconsistent with the predicate value | all tested (forms vary) |
| [02](bugs/02-boolean-operand-comparison/) | `WHERE (1 > 0) < c0` returns no rows although the predicate is 1 for two rows | all tested (forms vary) |
| [03](bugs/03-unique-index-join-null/) | Join on a UNIQUE-indexed column matches NULL to NULL | all tested |
| [04](bugs/04-range-join-where/) | BETWEEN join on an indexed column ignores a WHERE filter on the same table | all tested |
| [05](bugs/05-mod-negative-zero/) | `-5 MOD 5` returns `-0`, which is distinct from 0 in COUNT(DISTINCT) and in joins | 2.1.0+ |
| [06](bugs/06-three-table-filter-view/) | Predicate over two tables and a view gives a wrong count or an internal error | all tested (behavior varies) |
| [07](bugs/07-outer-join-conjunct/) | `A AND B` over a null-extended column keeps a row for which the predicate is NULL | all tested (forms vary) |
| [08](bugs/08-like-escape-column/) | `LIKE ... ESCAPE <column>` under UNION ALL raises `unable to find field with index N` | all tested |
| [09](bugs/09-fulltext-duplicate-rows/) | Multi-word `MATCH ... AGAINST` in WHERE returns a row twice | all tested |
| [10](bugs/10-fulltext-order-by/) | `ORDER BY` a FULLTEXT-indexed column returns no rows | all tested |
| [11](bugs/11-in-subquery-type-mismatch/) | `false NOT IN (SELECT 'W1q')` returns 1; `'a' IN (SELECT int_col)` with a NULL returns 0 | all tested |
| [12](bugs/12-scalar-subquery-not-equal/) | `c0 <> (SELECT ...)` keeps rows when the subquery is empty, and does not raise *more than 1 row* | all tested |
| [13](bugs/13-collate-index-lookup/) | Explicit `COLLATE` is ignored by a primary-key lookup | all tested |
| [14](bugs/14-view-column-list/) | View with a column list: `WHERE c0 = ...` is applied to the last column | 1.84.0+ |
| [15](bugs/15-decimal-literal-scale/) | DECIMAL(10,2) value 1.00 compares equal to 1.001; `CAST(2 AS DECIMAL(20,0)) > 1.5` is 0 | all tested (forms vary) |
| [16](bugs/16-row-null-datetime-null-safe-equal/) | `(CAST(NULL AS DATETIME), 5) <=> (1, 5)` returns 1 | 2.3.0+ |
| [17](bugs/17-json-extract-array-index-null-panic/) | `JSON_EXTRACT('{"a": null}', '$.a[0]')` panics | all tested |
| [18](bugs/18-json-extract-multi-path-panic/) | `JSON_EXTRACT` with several paths, one missing, panics | all tested |
| [19](bugs/19-match-against-derived-join-panic/) | `MATCH ... AGAINST` over a derived table or in `JOIN ... ON` drops the connection | all tested |
| [20](bugs/20-lookup-join-null-key-panic/) | LEFT JOIN `ON t0.c0 = NULL` as a lookup join drops the connection | all tested |
| [21](bugs/21-locate-empty-string-panic/) | `LOCATE('a', '', 2)` panics | all tested |
| [22](bugs/22-coalesce-decimal-out-of-range/) | `COALESCE(a, 1.5)` over an INT column raises `Out of range value for column of Decimal type` | all tested |
| [23](bugs/23-decimal-mod-division-impossible/) | `100000000 MOD 0.0001` and `1e30 MOD 7` raise `division impossible` | all tested (behavior varies) |

The wrong-result test cases include a control, such as the same predicate in the select list, an equivalent query, or a cross-join count. These controls show the inconsistency within Dolt; the MySQL comparison provides a separate reference.

## Versions

All cases reproduce on Dolt **2.4.2** and **master `ce68e18`** (built 2026-10-14, go-mysql-server `3f7a971bed2e`). We checked the version windows using `dolthub/dolt-sql-server` images 1.78.0, 1.84.0, 2.0.0, 2.1.0, 2.3.0, 2.3.5, 2.4.0, and 2.4.2. We did not test 2.2.x. MySQL 8.4.6 returns the expected results, except for case 08, where it rejects the test case.

Selected behavior changes across the sampled releases:

| Case and observed behavior | Last tested release without that behavior | First tested release with that behavior |
| --- | --- | --- |
| 14 | 1.78.0 | 1.84.0 |
| 07 (`IS NULL` form: internal error) | 1.78.0 | 1.84.0 |
| 05: negative zero; 23: `division impossible` | 2.0.0 | 2.1.0 |
| 06: wrong count and internal error; 16: wrong result | 2.1.0 | 2.3.0 |
| 01 (`TIMESTAMP` form: empty result) | 2.3.0 (out-of-range error) | 2.3.5 |
| 02 (`NOT` form: empty result) | 2.3.0 (all rows) | 2.3.5 |
| 15 (`CAST` form) | 2.3.5 | 2.4.0 |
| 01 (`TIME` form) | 2.4.0 | 2.4.2 |

For case 06, the second form already returned a wrong empty result in 2.1.0 and earlier; it raises an internal error from 2.3.0. For case 23, `1e30 MOD 7` returned a wrong value in 2.0.0 and earlier; it raises `division impossible` from 2.1.0. These are observations at sampled releases, not exact introduction points.

## Running a case

Start `dolt sql-server`, then run each test case in a fresh database. For example:

```sh
mysql -h 127.0.0.1 -P 3306 -u root -e 'CREATE DATABASE repro01'
mysql -h 127.0.0.1 -P 3306 -u root --force --table repro01 < bugs/01-index-mismatched-constant/repro.sql
```

`--force` keeps the client running past errors. In cases 19 and 20, the failing query drops the connection and the batch-mode client does not reconnect; run the failing queries in case 19 one at a time. The `-- Expected:` and `-- Actual:` comments give the expected result and the observed result on Dolt 2.4.2 and master. Rows marked "(any order)" may appear in a different order.

## Duplicate search

We screened the titles of issues in dolthub/dolt and dolthub/go-mysql-server and searched for terms specific to each case. We found no exact test case match. Related issues and possible overlaps are linked in the individual reports. A duplicate described only in an issue body could still have been missed. Please close or merge any cases already tracked.

Three further findings from the same testing are omitted. `NOT EXISTS (... LIMIT 0)` is already tracked in dolthub/dolt#10493. Row-value `IN (subquery)` with a NULL field is listed in go-mysql-server's known-broken queries. A hash join on mixed-type keys (BOOLEAN and VARCHAR) that misses matches is covered by dolthub/dolt#10316.
