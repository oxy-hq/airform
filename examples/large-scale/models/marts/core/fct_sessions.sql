with sessions as (
    select * from {{ ref('stg_sessions') }}
),

session_events as (
    select * from {{ ref('int_session_events') }}
),

session_pages as (
    select * from {{ ref('int_session_page_views') }}
),

final as (
    select
        sessions.session_id,
        sessions.user_id,
        sessions.started_at,
        sessions.ended_at,
        sessions.device_type,
        sessions.browser,
        sessions.referrer,
        sessions.landing_page,
        coalesce(session_events.event_count, 0) as event_count,
        coalesce(session_pages.page_view_count, 0) as page_view_count,
        coalesce(session_pages.distinct_pages, 0) as distinct_pages_viewed,
        coalesce(session_pages.total_time_seconds, 0) as total_time_seconds
    from sessions
    left join session_events on sessions.session_id = session_events.session_id
    left join session_pages on sessions.session_id = session_pages.session_id
)

select * from final
