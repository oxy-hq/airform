with accounts as (
    select * from {{ ref('stg_accounts') }}
),

plans as (
    select * from {{ ref('stg_account_plans') }}
),

industries as (
    select * from {{ ref('stg_account_industries') }}
),

user_counts as (
    select * from {{ ref('int_account_user_counts') }}
),

health as (
    select * from {{ ref('int_account_health') }}
),

final as (
    select
        accounts.account_id,
        accounts.account_name,
        accounts.status,
        plans.plan_name,
        plans.plan_price,
        industries.industry_vertical,
        industries.company_segment,
        accounts.company_size,
        accounts.created_at,
        coalesce(user_counts.total_users, 0) as total_users,
        coalesce(user_counts.active_users, 0) as active_users,
        coalesce(health.health_score, 0) as health_score,
        coalesce(health.total_revenue, 0) as total_revenue
    from accounts
    left join plans on accounts.account_id = plans.account_id
    left join industries on accounts.account_id = industries.account_id
    left join user_counts on accounts.account_id = user_counts.account_id
    left join health on accounts.account_id = health.account_id
)

select * from final
