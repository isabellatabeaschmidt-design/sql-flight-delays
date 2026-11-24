-- 03 Monthly on-time rate per airline and change versus the previous month

WITH big_airlines AS (
    SELECT carrier
    FROM flights
    GROUP BY carrier
    ORDER BY COUNT(*) DESC
    LIMIT 5
),
monthly AS (
    SELECT f.carrier,
           CAST(f.month AS INTEGER) AS month,
           ROUND(100.0 * SUM(CASE WHEN f.arr_delay <= 15 THEN 1 ELSE 0 END)
                       / COUNT(f.arr_delay), 1) AS on_time_pct
    FROM flights f
    WHERE f.carrier IN (SELECT carrier FROM big_airlines)
    GROUP BY f.carrier, CAST(f.month AS INTEGER)
)
SELECT carrier,
       month,
       on_time_pct,
       LAG(on_time_pct) OVER (PARTITION BY carrier ORDER BY month)               AS prev_month_pct,
       ROUND(on_time_pct - LAG(on_time_pct) OVER (PARTITION BY carrier ORDER BY month), 1)
                                                                                 AS change_pts
FROM monthly
ORDER BY carrier, month;
