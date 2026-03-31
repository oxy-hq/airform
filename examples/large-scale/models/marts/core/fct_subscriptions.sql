with subscriptions as (
    select * from {{ ref('stg_subscriptions') }}
),

accounts as (
    select * from {{ ref('stg_accounts') }}
),

plans as (
    select * from {{ ref('stg_account_plans') }}
),

mrr as (
    select * from {{ ref('int_subscription_mrr') }}
),

final as (
    select
        subscriptions.subscription_id,
        subscriptions.account_id,
        accounts.account_name,
        subscriptions.plan_id,
        plans.plan_name,
        subscriptions.status,
        subscriptions.monthly_amount,
        mrr.mrr,
        mrr.active_mrr,
        subscriptions.billing_interval,
        subscriptions.started_at,
        subscriptions.ended_at
    from subscriptions
    left join accounts on subscriptions.account_id = accounts.account_id
    left join plans on subscriptions.account_id = plans.account_id
    left join mrr on subscriptions.subscription_id = mrr.subscription_id
)

select * from final
