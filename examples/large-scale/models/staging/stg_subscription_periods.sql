with source as (
    select * from {{ source('raw', 'raw_subscriptions') }}
),

final as (
    select
        id as subscription_id,
        account_id,
        plan_id,
        started_at,
        ended_at,
        status,
        case
            when ended_at is null then 'ongoing'
            else 'ended'
        end as period_status
    from source
)

select * from final
