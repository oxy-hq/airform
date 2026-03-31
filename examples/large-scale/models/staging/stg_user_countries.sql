with source as (
    select * from {{ source('raw', 'raw_users') }}
),

final as (
    select
        id as user_id,
        country,
        case country
            when 'US' then 'North America'
            when 'CA' then 'North America'
            when 'UK' then 'Europe'
            when 'DE' then 'Europe'
            when 'FR' then 'Europe'
            else 'Other'
        end as region
    from source
)

select * from final
