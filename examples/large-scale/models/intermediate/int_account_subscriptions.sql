with subscriptions as (
    select * from {{ ref('stg_subscriptions') }}
),

accounts as (
    select * from {{ ref('stg_accounts') }}
),

plans as (
    select * from {{ ref('stg_account_plans') }}
),

final as (
    select
        subscriptions.subscription_id,
        subscriptions.account_id,
        accounts.account_name,
        plans.plan_name,
        subscriptions.monthly_amount,
        subscriptions.billing_interval,
        subscriptions.status,
        subscriptions.started_at,
        subscriptions.ended_at,
        row_number() over (partition by subscriptions.account_id order by subscriptions.started_at desc) as subscription_rank
    from subscriptions
    left join accounts on subscriptions.account_id = accounts.account_id
    left join plans on subscriptions.account_id = plans.account_id
)

select * from final
