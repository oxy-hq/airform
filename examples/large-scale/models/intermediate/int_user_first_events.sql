with events as (
    select * from {{ ref('stg_events') }}
),

first_events as (
    select
        user_id,
        min(event_timestamp) as first_event_at,
        min(case when event_name = 'page_view' then event_timestamp end) as first_page_view_at,
        min(case when event_name = 'button_click' then event_timestamp end) as first_click_at,
        min(case when event_name = 'feature_used' then event_timestamp end) as first_feature_use_at
    from events
    group by user_id
)

select * from first_events
