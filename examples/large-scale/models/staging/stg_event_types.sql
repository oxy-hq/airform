with source as (
    select * from {{ source('raw', 'raw_events') }}
),

final as (
    select
        id as event_id,
        user_id,
        event_type,
        event_name,
        case
            when event_name = 'page_view' then 'navigation'
            when event_name = 'button_click' then 'interaction'
            when event_name = 'feature_used' then 'engagement'
            else 'other'
        end as event_category,
        created_at as event_timestamp
    from source
)

select * from final
