with account_revenue as (
    select * from {{ ref('int_account_revenue') }}
),

account_tickets as (
    select * from {{ ref('int_account_tickets') }}
),

accounts as (
    select * from {{ ref('stg_accounts') }}
),

final as (
    select
        accounts.account_id,
        accounts.account_name,
        accounts.status,
        coalesce(account_revenue.total_collected, 0) as total_revenue,
        coalesce(account_tickets.total_tickets, 0) as total_tickets,
        coalesce(account_tickets.escalated_tickets, 0) as escalated_tickets,
        coalesce(account_tickets.avg_csat_score, 0) as avg_csat,
        case
            when accounts.status = 'churned' then 0
            when coalesce(account_tickets.escalated_tickets, 0) > 0 then 30
            when coalesce(account_tickets.avg_csat_score, 5) < 3 then 40
            when coalesce(account_revenue.total_collected, 0) > 0 then 80
            else 50
        end as health_score
    from accounts
    left join account_revenue on accounts.account_id = account_revenue.account_id
    left join account_tickets on accounts.account_id = account_tickets.account_id
)

select * from final
