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
        sum(mrr.active_mrr) * 12 as arr,
        sum(mrr.active_mrr) as mrr,
        count(distinct case when mrr.status = 'active' then mrr.subscription_id end) as active_subscriptions
    from accounts
    left join mrr on accounts.account_id = mrr.account_id
    group by accounts.account_id, accounts.account_name
)

select * from final
