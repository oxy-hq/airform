with engagement as (
    select * from {{ ref('int_user_engagement_scores') }}
),

features as (
    select * from {{ ref('int_user_feature_usage') }}
),

users as (
    select * from {{ ref('stg_users') }}
),

final as (
    select
        users.user_id,
        users.account_id,
        users.email,
        engagement.engagement_score,
        coalesce(features.features_used, 0) as features_used,
        coalesce(features.total_usage_count, 0) as total_usage_count,
        case
            when engagement.engagement_score >= 100 and coalesce(features.features_used, 0) >= 3 then 1
            else 0
        end as is_power_user
    from users
    left join engagement on users.user_id = engagement.user_id
    left join features on users.user_id = features.user_id
    where users.status = 'active'
)

select * from final
