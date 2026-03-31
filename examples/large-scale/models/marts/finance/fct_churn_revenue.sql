with subscriptions as (
    select * from {{ ref('stg_subscriptions') }}
),

accounts as (
    select * from {{ ref('stg_accounts') }}
),

final as (
    select
        subscriptions.subscription_id,
        subscriptions.account_id,
        accounts.account_name,
        subscriptions.monthly_amount as churned_mrr,
        subscriptions.monthly_amount * 12 as churned_arr,
        subscriptions.ended_at as churn_date,
        subscriptions.plan_id
    from subscriptions
    left join accounts on subscriptions.account_id = accounts.account_id
    where subscriptions.status = 'cancelled' and subscriptions.ended_at is not null
)

select * from final
