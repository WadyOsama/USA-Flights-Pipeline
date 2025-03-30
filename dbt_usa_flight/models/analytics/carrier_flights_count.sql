{{
    config(
        materialized='view'
    )
}}

with source as (
    SELECT * FROM {{ ref('fact_flights') }}
),
carrier_flights as (
    SELECT UniqueCarrier, Year, Month, COUNT(*) AS FlightsCount
    FROM source
    GROUP BY UniqueCarrier, Year, Month
)

SELECT Description AS Carrier, Year, Month, FlightsCount
FROM carrier_flights AS F
JOIN {{ ref('carriers') }} AS C
ON F.UniqueCarrier = C.Code
ORDER BY Carrier, Year, Month
