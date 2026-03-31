with source as (
    select * from {{ source('raw', 'raw_accounts') }}
),

final as (
    select
        id as account_id,
        plan_id,
        case plan_id
            when 1 then 'free'
            when 2 then 'starter'
            when 3 then 'professional'
            when 4 then 'enterprise'
            else 'unknown'
        end as plan_name,
        case plan_id
            when 1 then 0
            when 2 then 99
            when 3 then 249
            when 4 then 499
            else 0
        end as plan_price
    from source
)

select * from final
