with users as (
    select * from {{ ref('stg_users') }}
),

engagement as (
    select * from {{ ref('int_user_engagement_scores') }}
),

features as (
    select * from {{ ref('int_user_feature_usage') }}
),

accounts as (
    select * from {{ ref('stg_accounts') }}
),

final as (
    select
        users.user_id,
        users.account_id,
        accounts.account_name,
        accounts.company_size,
        coalesce(engagement.engagement_score, 0) as engagement_score,
        coalesce(features.features_used, 0) as features_used,
        coalesce(features.total_usage_count, 0) as total_usage,
        case
            when coalesce(engagement.engagement_score, 0) >= 50
                and coalesce(features.features_used, 0) >= 2
                and accounts.company_size >= 50
            then 1
            else 0
        end as is_pql,
        case
            when coalesce(engagement.engagement_score, 0) >= 100 then 'hot'
            when coalesce(engagement.engagement_score, 0) >= 50 then 'warm'
            else 'cold'
        end as lead_temperature
    from users
    left join engagement on users.user_id = engagement.user_id
    left join features on users.user_id = features.user_id
    left join accounts on users.account_id = accounts.account_id
    where users.status in ('active', 'trial')
)

select * from final
