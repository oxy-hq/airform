with plans as (
    select * from {{ ref('stg_account_plans') }}
),

revenue as (
    select * from {{ ref('int_revenue_by_plan') }}
),

final as (
    select distinct
        plans.plan_id,
        plans.plan_name,
        plans.plan_price,
        coalesce(revenue.subscription_count, 0) as total_subscriptions,
        coalesce(revenue.account_count, 0) as total_accounts,
        coalesce(revenue.total_monthly_revenue, 0) as total_monthly_revenue,
        case plans.plan_id
            when 1 then 'self_serve'
            when 2 then 'self_serve'
            when 3 then 'sales_assisted'
            when 4 then 'enterprise_sales'
            else 'unknown'
        end as sales_motion
    from plans
    left join revenue on plans.plan_id = revenue.plan_id
)

select * from final
