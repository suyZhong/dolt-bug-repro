SELECT LOCATE('a', 'abc', 2), LOCATE('a', '', 1);
-- 0, 0

SELECT LOCATE('a', '', 2);
-- Expected: 0
-- Actual:   ERROR 1105 (HY000): panic recovered: runtime error: slice bounds out of range [1:0]
