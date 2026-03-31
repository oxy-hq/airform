with users as (
    select * from {{ ref('stg_users') }}
),

engagement as (
    select * from {{ ref('int_user_engagement_scores') }}
),

features as (
    select * from {{ ref('int_user_feature_usage') }}
),

categories as (
    select * from {{ ref('stg_feature_categories') }}
),

user_top_category as (
    select
        user_id,
        feature_category,
        row_number() over (partition by user_id order by count(*) desc) as rn
    from categories
    group by user_id, feature_category
),

final as (
    select
        users.user_id,
        users.status,
        coalesce(engagement.engagement_score, 0) as engagement_score,
        coalesce(features.features_used, 0) as features_used,
        user_top_category.feature_category as primary_feature_category,
        case
            when user_top_category.feature_category = 'developer' then 'developer'
            when user_top_category.feature_category = 'analytics' then 'analyst'
            when user_top_category.feature_category = 'admin' then 'admin'
            else 'general'
        end as persona
    from users
    left join engagement on users.user_id = engagement.user_id
    left join features on users.user_id = features.user_id
    left join user_top_category on users.user_id = user_top_category.user_id and user_top_category.rn = 1
)

select * from final
