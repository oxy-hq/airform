with account_revenue as (
    select * from {{ ref('int_account_revenue') }}
),

accounts as (
    select * from {{ ref('stg_accounts') }}
),

mrr as (
    select * from {{ ref('int_subscription_mrr') }}
),

current_mrr as (
    select
        account_id,
        sum(active_mrr) as current_mrr
    from mrr
    group by account_id
),

final as (
    select
        accounts.account_id,
        accounts.account_name,
        accounts.status,
        coalesce(account_revenue.total_collected, 0) as total_revenue,
        coalesce(current_mrr.current_mrr, 0) as current_mrr,
        coalesce(account_revenue.paid_revenue, 0) as paid_revenue,
        coalesce(account_revenue.outstanding_revenue, 0) as outstanding_revenue
    from accounts
    left join account_revenue on accounts.account_id = account_revenue.account_id
    left join current_mrr on accounts.account_id = current_mrr.account_id
)

select * from final
