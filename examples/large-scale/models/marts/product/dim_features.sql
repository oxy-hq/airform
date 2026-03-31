with feature_usage as (
    select * from {{ ref('stg_feature_usage') }}
),

categories as (
    select * from {{ ref('stg_feature_categories') }}
),

feature_stats as (
    select
        feature_usage.feature_name,
        count(distinct feature_usage.user_id) as total_users,
        sum(feature_usage.usage_count) as total_usage,
        avg(feature_usage.duration_seconds) as avg_duration,
        min(feature_usage.used_at) as first_usage_at,
        max(feature_usage.used_at) as last_usage_at
    from feature_usage
    group by feature_usage.feature_name
),

final as (
    select distinct
        feature_stats.feature_name,
        categories.feature_category,
        feature_stats.total_users,
        feature_stats.total_usage,
        feature_stats.avg_duration,
        feature_stats.first_usage_at,
        feature_stats.last_usage_at
    from feature_stats
    left join categories on feature_stats.feature_name = categories.feature_name
)

select * from final
