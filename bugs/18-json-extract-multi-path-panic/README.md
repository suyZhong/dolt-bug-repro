# Panic in JSON_EXTRACT with several paths when one path is missing

**Affected:** Every tested release (1.78.0 through 2.4.2) and master.

## What happens

`JSON_EXTRACT` with two or more paths, at least one of which does not exist, fails with `panic recovered: runtime error: invalid memory address or nil pointer dereference`. MySQL returns the array of values found, here `[1]`. With all paths present, Dolt returns the expected result. The stack trace goes through `types.ConcatenateJSONValues`. The fixed dolthub/dolt#9134 involved a NULL path argument.

## Test case

Run in a fresh database ([repro.sql](repro.sql)):

```sql
SELECT JSON_EXTRACT('{"a": 1}', '$.a', '$.a');
-- [1, 1]

SELECT JSON_EXTRACT('{"a": 1}', '$.nope', '$.a');
-- Expected: [1]
-- Actual:   ERROR 1105 (HY000): panic recovered: runtime error: invalid memory address or nil pointer dereference
```

Verified through the MySQL protocol on Dolt 2.4.2 and master `ce68e18` (2026-10-14). MySQL 8.4.6 returns the expected results.
