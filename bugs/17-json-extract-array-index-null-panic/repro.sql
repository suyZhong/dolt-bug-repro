SELECT JSON_EXTRACT('{"a": [5]}', '$.a[0]');
-- 5

SELECT JSON_EXTRACT('{"a": null}', '$.a[0]');
-- Expected: null
-- Actual:   ERROR 1105 (HY000): panic recovered: runtime error: invalid memory address or nil pointer dereference
