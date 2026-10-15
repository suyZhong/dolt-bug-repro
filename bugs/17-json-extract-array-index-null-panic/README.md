# Panic in JSON_EXTRACT when an array index is applied to a JSON null

**Affected:** Every tested release (1.78.0 through 2.4.2) and master.

## What happens

`JSON_EXTRACT('{"a": null}', '$.a[0]')` fails with `panic recovered: runtime error: invalid memory address or nil pointer dereference`. MySQL returns JSON `null`. The stack trace goes through `jsonpath.get_idx`, called from `(*JSONExtract).Eval`. On Dolt 2.4.2, `'$.a[1]'` also panics; MySQL returns SQL NULL. The `[0]` expectation follows MySQL's path rule for non-array values. The open dolthub/dolt#7936 tracks related JSON lookup behavior on non-array values.

## Test case

Run in a fresh database ([repro.sql](repro.sql)):

```sql
SELECT JSON_EXTRACT('{"a": [5]}', '$.a[0]');
-- 5

SELECT JSON_EXTRACT('{"a": null}', '$.a[0]');
-- Expected: null
-- Actual:   ERROR 1105 (HY000): panic recovered: runtime error: invalid memory address or nil pointer dereference
```

Verified through the MySQL protocol on Dolt 2.4.2 and master `ce68e18` (2026-10-14). MySQL 8.4.6 returns the expected results.
