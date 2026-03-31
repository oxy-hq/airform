with accounts as (
    select * from {{ ref('stg_accounts') }}
),

account_revenue as (
    select * from {{ ref('int_account_revenue') }}
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
        coalesce(account_revenue.total_collected, 0) as revenue_to_date,
        coalesce(current_mrr.current_mrr, 0) as current_mrr,
        coalesce(current_mrr.current_mrr, 0) * 24 as estimated_ltv_24m,
        case
            when accounts.status = 'churned' then coalesce(account_revenue.total_collected, 0)
            else coalesce(current_mrr.current_mrr, 0) * 36
        end as projected_ltv
    from accounts
    left join account_revenue on accounts.account_id = account_revenue.account_id
    left join current_mrr on accounts.account_id = current_mrr.account_id
)

select * from final
