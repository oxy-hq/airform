with revenue_by_plan as (
    select * from {{ ref('int_revenue_by_plan') }}
),

plans as (
    select * from {{ ref('stg_account_plans') }}
),

final as (
    select distinct
        revenue_by_plan.plan_id,
        plans.plan_name,
        revenue_by_plan.subscription_count,
        revenue_by_plan.account_count,
        revenue_by_plan.total_monthly_revenue,
        revenue_by_plan.active_monthly_revenue,
        revenue_by_plan.active_monthly_revenue * 12 as active_annual_revenue,
        case
            when revenue_by_plan.subscription_count > 0
            then revenue_by_plan.total_monthly_revenue / revenue_by_plan.subscription_count
            else 0
        end as avg_revenue_per_subscription
    from revenue_by_plan
    left join plans on revenue_by_plan.plan_id = plans.plan_id
)

select * from final
