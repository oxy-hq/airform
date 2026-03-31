with daily_events as (
    select * from {{ ref('int_daily_events') }}
),

users as (
    select * from {{ ref('stg_users') }}
),

final as (
    select
        daily_events.event_date as activity_date,
        count(distinct daily_events.user_id) as daily_active_users,
        sum(daily_events.event_count) as total_events,
        sum(daily_events.session_count) as total_sessions,
        avg(daily_events.event_count) as avg_events_per_user
    from daily_events
    left join users on daily_events.user_id = users.user_id
    where users.status != 'churned'
    group by daily_events.event_date
)

select * from final
