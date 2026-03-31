with sessions as (
    select * from {{ ref('stg_sessions') }}
),

events as (
    select * from {{ ref('stg_events') }}
),

event_counts as (
    select
        session_id,
        count(*) as event_count,
        count(distinct event_name) as distinct_event_types
    from events
    group by session_id
),

final as (
    select
        sessions.session_id,
        sessions.user_id,
        sessions.started_at,
        sessions.ended_at,
        sessions.device_type,
        coalesce(event_counts.event_count, 0) as event_count,
        coalesce(event_counts.distinct_event_types, 0) as distinct_event_types
    from sessions
    left join event_counts on sessions.session_id = event_counts.session_id
)

select * from final
