-- 04 The three routes with the highest average arrival delay from each New York airport

WITH routes AS (
    SELECT f.origin,
           f.dest,
           ap.name                       AS dest_name,
           COUNT(*)                      AS flights,
           ROUND(AVG(f.arr_delay), 1)    AS avg_arr_delay_min
    FROM flights f
    LEFT JOIN airports ap ON ap.faa = f.dest
    GROUP BY f.origin, f.dest
    HAVING COUNT(*) >= 365
),
ranked AS (
    SELECT *,
           RANK() OVER (PARTITION BY origin ORDER BY avg_arr_delay_min DESC) AS delay_rank
    FROM routes
)
SELECT origin, delay_rank, dest, dest_name, flights, avg_arr_delay_min
FROM ranked
WHERE delay_rank <= 3
ORDER BY origin, delay_rank;
