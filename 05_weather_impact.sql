-- 05 How much does visibility at departure explain delays?

SELECT CASE
           WHEN w.visib < 1  THEN '1: under 1 mile'
           WHEN w.visib < 3  THEN '2: 1 to 3 miles'
           WHEN w.visib < 10 THEN '3: 3 to 10 miles'
           ELSE                   '4: 10 miles (clear)'
       END                                                             AS visibility,
       COUNT(*)                                                        AS flights,
       ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 1)              AS share_of_flights_pct,
       ROUND(AVG(f.dep_delay), 1)                                      AS avg_dep_delay_min,
       ROUND(100.0 * SUM(CASE WHEN f.dep_delay > 15 THEN 1 ELSE 0 END)
                   / COUNT(f.dep_delay), 1)                            AS delayed_over_15_pct
FROM flights f
JOIN weather w
  ON w.origin = f.origin
 AND w.time_hour = f.time_hour
WHERE f.dep_delay IS NOT NULL
  AND w.visib IS NOT NULL
GROUP BY visibility
ORDER BY visibility;
