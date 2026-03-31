with accounts as (
    select * from {{ ref('stg_accounts') }}
),

subscriptions as (
    select * from {{ ref('stg_subscriptions') }}
),

final as (
    select
        accounts.account_id,
        accounts.account_name,
        subscriptions.subscription_id,
        subscriptions.status as subscription_status,
        subscriptions.monthly_amount,
        subscriptions.started_at as subscription_started_at,
        accounts.created_at as account_created_at,
        case
            when subscriptions.status = 'active' and subscriptions.monthly_amount > 0 then 1
            else 0
        end as is_converted
    from accounts
    left join subscriptions on accounts.account_id = subscriptions.account_id
)

select * from final
