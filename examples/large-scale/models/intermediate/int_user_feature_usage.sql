with feature_usage as (
    select * from {{ ref('stg_feature_usage') }}
),

final as (
    select
        user_id,
        count(distinct feature_name) as features_used,
        sum(usage_count) as total_usage_count,
        sum(duration_seconds) as total_usage_duration,
        min(used_at) as first_feature_use_at,
        max(used_at) as last_feature_use_at,
        max(usage_count) as max_single_feature_usage
    from feature_usage
    group by user_id
)

select * from final
