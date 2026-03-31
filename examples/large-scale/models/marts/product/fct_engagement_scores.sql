with engagement as (
    select * from {{ ref('int_user_engagement_scores') }}
),

users as (
    select * from {{ ref('stg_users') }}
),

final as (
    select
        engagement.user_id,
        users.account_id,
        users.status,
        engagement.session_count,
        engagement.event_count,
        engagement.features_used,
        engagement.engagement_score,
        case
            when engagement.engagement_score >= 100 then 'highly_engaged'
            when engagement.engagement_score >= 50 then 'engaged'
            when engagement.engagement_score >= 10 then 'low_engagement'
            else 'inactive'
        end as engagement_tier,
        row_number() over (order by engagement.engagement_score desc) as engagement_rank
    from engagement
    left join users on engagement.user_id = users.user_id
)

select * from final
