-- 02 Punctuality by airline

SELECT a.name                                                         AS airline,
       COUNT(*)                                                       AS flights,
       ROUND(100.0 * SUM(f.dep_time IS NULL) / COUNT(*), 1)           AS cancelled_pct,
       ROUND(100.0 * SUM(CASE WHEN f.arr_delay <= 15 THEN 1 ELSE 0 END)
                   / COUNT(f.arr_delay), 1)                           AS on_time_pct,
       ROUND(AVG(f.arr_delay), 1)                                     AS avg_arr_delay_min
FROM flights f
JOIN airlines a ON a.carrier = f.carrier
GROUP BY a.name
HAVING COUNT(*) >= 1000
ORDER BY on_time_pct DESC;
