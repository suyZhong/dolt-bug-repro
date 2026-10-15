SELECT JSON_EXTRACT('{"a": 1}', '$.a', '$.a');
-- [1, 1]

SELECT JSON_EXTRACT('{"a": 1}', '$.nope', '$.a');
-- Expected: [1]
-- Actual:   ERROR 1105 (HY000): panic recovered: runtime error: invalid memory address or nil pointer dereference
