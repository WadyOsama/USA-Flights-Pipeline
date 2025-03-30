{{
    config(
        materialized='view'
    )
}}

with 
source as (
    select * from {{ ref('fact_flights') }}
),
flights_count as (
    SELECT Year, Origin, COUNT(*) AS FlightsCount
    FROM source
    GROUP BY Year, Origin 
),
ranking_airports as (
    SELECT
        RANK() OVER(PARTITION BY Year ORDER BY FlightsCount DESC) AS AirportRank,
        Year, Origin, FlightsCount
    FROM flights_count
)

SELECT 
    Year,
    AirportRank,
    airport AS Airport,
    city AS City,
    FlightsCount
FROM ranking_airports AS R
JOIN {{ ref('airports') }} AS A
ON R.Origin = A.iata
WHERE AirportRank <= 10
ORDER BY Year DESC, AirportRank 