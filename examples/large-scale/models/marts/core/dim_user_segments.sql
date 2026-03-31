with users as (
    select * from {{ ref('stg_users') }}
),

engagement as (
    select * from {{ ref('int_user_engagement_scores') }}
),

features as (
    select * from {{ ref('int_user_feature_usage') }}
),

final as (
    select
        users.user_id,
        users.status,
        users.signup_source,
        coalesce(engagement.engagement_score, 0) as engagement_score,
        coalesce(features.features_used, 0) as features_used,
        case
            when coalesce(engagement.engagement_score, 0) >= 100 then 'power_user'
            when coalesce(engagement.engagement_score, 0) >= 50 then 'active'
            when coalesce(engagement.engagement_score, 0) >= 10 then 'casual'
            else 'dormant'
        end as engagement_segment,
        case
            when coalesce(features.features_used, 0) >= 4 then 'full_adopter'
            when coalesce(features.features_used, 0) >= 2 then 'partial_adopter'
            when coalesce(features.features_used, 0) >= 1 then 'beginner'
            else 'no_adoption'
        end as adoption_segment
    from users
    left join engagement on users.user_id = engagement.user_id
    left join features on users.user_id = features.user_id
)

select * from final
