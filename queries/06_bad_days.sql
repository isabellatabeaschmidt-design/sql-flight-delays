-- 06 Which days were unusually bad compared with the week before?

WITH daily AS (
    SELECT printf('%04d-%02d-%02d', year, month, day) AS flight_date,
           COUNT(*)                                   AS flights,
           AVG(dep_delay)                             AS avg_dep_delay
    FROM flights
    GROUP BY year, month, day
),
rolling AS (
    SELECT flight_date,
           flights,
           avg_dep_delay,
           AVG(avg_dep_delay) OVER (
               ORDER BY flight_date
               ROWS BETWEEN 7 PRECEDING AND 1 PRECEDING
           ) AS prev_7d_avg
    FROM daily
)
SELECT flight_date,
       flights,
       ROUND(avg_dep_delay, 1)                 AS avg_dep_delay_min,
       ROUND(prev_7d_avg, 1)                   AS prev_7d_avg_min,
       ROUND(avg_dep_delay - prev_7d_avg, 1)   AS jump_min,
       ROUND(avg_dep_delay / prev_7d_avg, 1)   AS times_normal
FROM rolling
WHERE prev_7d_avg IS NOT NULL
  AND avg_dep_delay > 2 * prev_7d_avg
ORDER BY jump_min DESC
LIMIT 10;
