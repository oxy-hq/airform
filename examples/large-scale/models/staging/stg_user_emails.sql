with source as (
    select * from {{ source('raw', 'raw_users') }}
),

final as (
    select
        id as user_id,
        email,
        case
            when email like '%@gmail.com' then 'gmail'
            when email like '%@yahoo.com' then 'yahoo'
            else 'business'
        end as email_domain_type
    from source
)

select * from final
