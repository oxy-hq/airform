with subscriptions as (
    select * from {{ ref('stg_subscriptions') }}
),

final as (
    select
        subscription_id,
        account_id,
        plan_id,
        status,
        monthly_amount,
        case
            when billing_interval = 'annual' then monthly_amount / 12
            else monthly_amount
        end as mrr,
        case
            when status in ('active') then monthly_amount
            else 0
        end as active_mrr,
        started_at,
        ended_at
    from subscriptions
)

select * from final
