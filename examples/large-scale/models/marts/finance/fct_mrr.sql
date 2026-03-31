with mrr as (
    select * from {{ ref('int_subscription_mrr') }}
),

accounts as (
    select * from {{ ref('stg_accounts') }}
),

final as (
    select
        accounts.account_id,
        accounts.account_name,
        sum(mrr.mrr) as total_mrr,
        sum(mrr.active_mrr) as active_mrr,
        count(distinct mrr.subscription_id) as subscription_count,
        sum(case when mrr.status = 'active' then 1 else 0 end) as active_subscriptions
    from accounts
    left join mrr on accounts.account_id = mrr.account_id
    group by accounts.account_id, accounts.account_name
)

select * from final
