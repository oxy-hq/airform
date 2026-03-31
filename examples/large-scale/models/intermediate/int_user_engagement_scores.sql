with user_sessions as (
    select * from {{ ref('int_user_sessions') }}
),

user_events as (
    select * from {{ ref('int_user_events') }}
),

user_features as (
    select * from {{ ref('int_user_feature_usage') }}
),

final as (
    select
        user_sessions.user_id,
        coalesce(user_sessions.total_sessions, 0) as session_count,
        coalesce(user_events.total_events, 0) as event_count,
        coalesce(user_features.features_used, 0) as features_used,
        (
            coalesce(user_sessions.total_sessions, 0) * 10
            + coalesce(user_events.total_events, 0) * 2
            + coalesce(user_features.features_used, 0) * 20
        ) as engagement_score
    from user_sessions
    left join user_events on user_sessions.user_id = user_events.user_id
    left join user_features on user_sessions.user_id = user_features.user_id
)

select * from final
