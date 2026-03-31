with feature_usage as (
    select * from {{ ref('stg_feature_usage') }}
),

categories as (
    select * from {{ ref('stg_feature_categories') }}
),

users as (
    select * from {{ ref('stg_users') }}
),

final as (
    select
        feature_usage.feature_usage_id,
        feature_usage.user_id,
        users.account_id,
        feature_usage.feature_name,
        categories.feature_category,
        feature_usage.usage_count,
        feature_usage.duration_seconds,
        feature_usage.used_at,
        cast(feature_usage.used_at as date) as usage_date
    from feature_usage
    left join categories on feature_usage.feature_usage_id = categories.feature_usage_id
    left join users on feature_usage.user_id = users.user_id
)

select * from final
