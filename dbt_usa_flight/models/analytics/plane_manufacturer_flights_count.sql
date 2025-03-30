{{
    config(
        materialized='view'
    )
}}

with source as (
    SELECT * FROM {{ ref('fact_flights') }}
),
plane_flights as (
    SELECT TailNum, Year, Month, COUNT(*) AS FlightsCount
    FROM source
    GROUP BY TailNum, Year, Month
)

SELECT P.manufacturer AS Manufacturer, F.Year, F.Month, SUM(F.FlightsCount) AS FlightsCount
FROM plane_flights AS F
JOIN {{ source('analytics', 'planes') }} AS P
ON F.TailNum = P.tailnum
WHERE Manufacturer != ''
GROUP BY Manufacturer, Year, Month
ORDER BY Manufacturer, Year ASC, Month ASC