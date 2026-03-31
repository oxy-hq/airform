with feature_usage as (
    select * from {{ ref('stg_feature_usage') }}
),

user_feature_days as (
    select
        feature_name,
        user_id,
        count(distinct cast(used_at as date)) as days_used,
        min(used_at) as first_used_at,
        max(used_at) as last_used_at
    from feature_usage
    group by feature_name, user_id
),

final as (
    select
        feature_name,
        count(distinct user_id) as total_users,
        count(distinct case when days_used >= 2 then user_id end) as returning_users,
        case
            when count(distinct user_id) > 0
            then cast(count(distinct case when days_used >= 2 then user_id end) as float)
                / cast(count(distinct user_id) as float)
            else 0
        end as retention_rate,
        avg(days_used) as avg_days_used
    from user_feature_days
    group by feature_name
)

select * from final
