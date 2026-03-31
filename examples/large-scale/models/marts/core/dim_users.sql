with users as (
    select * from {{ ref('stg_users') }}
),

user_countries as (
    select * from {{ ref('stg_user_countries') }}
),

engagement as (
    select * from {{ ref('int_user_engagement_scores') }}
),

final as (
    select
        users.user_id,
        users.account_id,
        users.email,
        users.first_name,
        users.last_name,
        users.status,
        users.country,
        user_countries.region,
        users.signup_source,
        users.created_at,
        users.updated_at,
        coalesce(engagement.engagement_score, 0) as engagement_score,
        coalesce(engagement.session_count, 0) as total_sessions,
        coalesce(engagement.event_count, 0) as total_events,
        coalesce(engagement.features_used, 0) as features_used
    from users
    left join user_countries on users.user_id = user_countries.user_id
    left join engagement on users.user_id = engagement.user_id
)

select * from final
