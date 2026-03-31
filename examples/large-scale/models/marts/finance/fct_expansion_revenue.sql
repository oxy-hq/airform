with account_subs as (
    select * from {{ ref('int_account_subscriptions') }}
),

final as (
    select
        account_id,
        account_name,
        subscription_id,
        plan_name,
        monthly_amount,
        started_at,
        subscription_rank,
        case
            when subscription_rank > 1 then 'expansion'
            else 'new'
        end as revenue_type
    from account_subs
    where status in ('active', 'cancelled')
)

select * from final
