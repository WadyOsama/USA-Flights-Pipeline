{#
    This macro returns the reason of cancellation for the flight depending on CancellationCode
#}

{% macro get_cancellation_reason(CancellationCode) -%}

    case lower({{CancellationCode }})
        when 'a' then 'Carrier'
        when 'b' then 'Weather'
        when 'c' then 'NAS'
        when 'd' then 'Security'
        else NULL
    end

{%- endmacro %}`