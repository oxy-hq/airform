with user_sessions as (
    select * from {{ ref('int_user_sessions') }}
),

daily_events as (
    select * from {{ ref('int_daily_events') }}
),

active_days as (
    select
        user_id,
        count(distinct event_date) as days_active
    from daily_events
    group by user_id
),

final as (
    select
        user_sessions.user_id,
        user_sessions.total_sessions,
        coalesce(active_days.days_active, 0) as days_active,
        user_sessions.first_session_at,
        user_sessions.last_session_at,
        case
            when coalesce(active_days.days_active, 0) >= 5 then 'very_sticky'
            when coalesce(active_days.days_active, 0) >= 3 then 'sticky'
            when coalesce(active_days.days_active, 0) >= 1 then 'occasional'
            else 'inactive'
        end as stickiness_tier
    from user_sessions
    left join active_days on user_sessions.user_id = active_days.user_id
)

select * from final
