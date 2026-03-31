with events as (
    select * from {{ ref('stg_events') }}
),

final as (
    select
        user_id,
        count(*) as total_events,
        count(distinct event_name) as distinct_event_types,
        min(event_timestamp) as first_event_at,
        max(event_timestamp) as last_event_at,
        sum(case when event_name = 'page_view' then 1 else 0 end) as page_view_events,
        sum(case when event_name = 'button_click' then 1 else 0 end) as click_events,
        sum(case when event_name = 'feature_used' then 1 else 0 end) as feature_events
    from events
    group by user_id
)

select * from final
