-- 01 Data quality: what can I trust before I analyse anything?

SELECT 'flights in total' AS check_name,
       COUNT(*)           AS value
FROM flights

UNION ALL
SELECT 'cancelled (no dep_time)', COUNT(*)
FROM flights
WHERE dep_time IS NULL

UNION ALL
SELECT 'departed, but arr_delay missing', COUNT(*)
FROM flights
WHERE dep_time IS NOT NULL AND arr_delay IS NULL

UNION ALL
SELECT 'flights whose tailnum is not in planes', COUNT(*)
FROM flights f
LEFT JOIN planes p ON p.tailnum = f.tailnum
WHERE f.tailnum IS NOT NULL AND p.tailnum IS NULL

UNION ALL
SELECT 'duplicate flight keys', COUNT(*)
FROM (
    SELECT year, month, day, carrier, flight, origin
    FROM flights
    GROUP BY year, month, day, carrier, flight, origin
    HAVING COUNT(*) > 1
)

UNION ALL
SELECT 'flights without weather record', COUNT(*)
FROM flights f
LEFT JOIN weather w ON w.origin = f.origin AND w.time_hour = f.time_hour
WHERE w.origin IS NULL;
