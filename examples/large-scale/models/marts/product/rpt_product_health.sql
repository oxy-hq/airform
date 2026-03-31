with adoption as (
    select * from {{ ref('int_feature_adoption') }}
),

feature_usage as (
    select * from {{ ref('stg_feature_usage') }}
),

usage_trend as (
    select
        feature_name,
        count(distinct user_id) as recent_users,
        sum(usage_count) as recent_usage
    from feature_usage
    group by feature_name
),

final as (
    select
        adoption.feature_name,
        adoption.users_using,
        adoption.adoption_rate,
        adoption.total_usage,
        adoption.avg_duration,
        coalesce(usage_trend.recent_users, 0) as recent_active_users,
        coalesce(usage_trend.recent_usage, 0) as recent_total_usage,
        case
            when adoption.adoption_rate >= 0.5 then 'healthy'
            when adoption.adoption_rate >= 0.2 then 'moderate'
            else 'at_risk'
        end as health_status
    from adoption
    left join usage_trend on adoption.feature_name = usage_trend.feature_name
)

select * from final
