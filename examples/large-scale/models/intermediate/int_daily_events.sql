with events as (
    select * from {{ ref('stg_events') }}
),

final as (
    select
        user_id,
        cast(event_timestamp as date) as event_date,
        count(*) as event_count,
        count(distinct event_name) as distinct_events,
        count(distinct session_id) as session_count
    from events
    group by user_id, cast(event_timestamp as date)
)

select * from final
