with subscriptions as (
    select * from {{ ref('stg_subscriptions') }}
),

plans as (
    select * from {{ ref('stg_account_plans') }}
),

final as (
    select
        subscriptions.plan_id,
        plans.plan_name,
        count(distinct subscriptions.subscription_id) as subscription_count,
        count(distinct subscriptions.account_id) as account_count,
        sum(subscriptions.monthly_amount) as total_monthly_revenue,
        avg(subscriptions.monthly_amount) as avg_monthly_revenue,
        sum(case when subscriptions.status = 'active' then subscriptions.monthly_amount else 0 end) as active_monthly_revenue
    from subscriptions
    left join plans on subscriptions.account_id = plans.account_id
    group by subscriptions.plan_id, plans.plan_name
)

select * from final
