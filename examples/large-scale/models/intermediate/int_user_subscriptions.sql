with users as (
    select * from {{ ref('stg_users') }}
),

subscriptions as (
    select * from {{ ref('stg_subscriptions') }}
),

plans as (
    select * from {{ ref('stg_account_plans') }}
),

final as (
    select
        users.user_id,
        users.account_id,
        subscriptions.subscription_id,
        subscriptions.status as subscription_status,
        subscriptions.monthly_amount,
        plans.plan_name,
        plans.plan_price,
        subscriptions.started_at as subscription_started_at,
        subscriptions.ended_at as subscription_ended_at
    from users
    left join subscriptions on users.account_id = subscriptions.account_id
    left join plans on subscriptions.account_id = plans.account_id
)

select * from final
