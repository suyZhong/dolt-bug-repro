SELECT 476098643 MOD 0.5962;
-- 0.5652

SELECT 100000000 MOD 0.0001;
-- Expected: 0.0000
-- Actual:   ERROR 1105 (HY000): division impossible

SELECT 1e30 MOD 7;
-- Expected: 5
-- Actual:   ERROR 1105 (HY000): division impossible
