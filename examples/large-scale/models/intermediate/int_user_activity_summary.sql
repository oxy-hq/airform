with user_sessions as (
    select * from {{ ref('int_user_sessions') }}
),

user_events as (
    select * from {{ ref('int_user_events') }}
),

user_page_views as (
    select * from {{ ref('int_user_page_views') }}
),

users as (
    select * from {{ ref('stg_users') }}
),

final as (
    select
        users.user_id,
        users.status,
        users.created_at as user_created_at,
        coalesce(user_sessions.total_sessions, 0) as total_sessions,
        coalesce(user_events.total_events, 0) as total_events,
        coalesce(user_page_views.total_page_views, 0) as total_page_views,
        user_sessions.first_session_at,
        user_sessions.last_session_at,
        user_events.first_event_at,
        user_events.last_event_at
    from users
    left join user_sessions on users.user_id = user_sessions.user_id
    left join user_events on users.user_id = user_events.user_id
    left join user_page_views on users.user_id = user_page_views.user_id
)

select * from final
