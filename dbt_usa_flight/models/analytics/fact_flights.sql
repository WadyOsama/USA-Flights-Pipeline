with 

source as (

    select * from {{ source('analytics', 'flights') }}

),

renamed as (

    select
        unique_row_id,
        flightdate,
        year,
        month,
        dayofmonth,
        dayofweek,
        deptime,
        crsdeptime,
        arrtime,
        crsarrtime,
        uniquecarrier,
        flightnum,
        tailnum,
        actualelapsedtime,
        crselapsedtime,
        airtime,
        arrdelay,
        depdelay,
        origin,
        dest,
        distance,
        taxiin,
        taxiout,
        cancelled,
        {{ get_cancellation_reason('cancellationcode') }} AS cancellationreason,
        diverted,
        carrierdelay,
        weatherdelay,
        nasdelay,
        securitydelay,
        lateaircraftdelay

    from source

)

select * from renamed
