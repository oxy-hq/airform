with source as (
    select * from {{ source('raw', 'raw_events') }}
),

final as (
    select
        id as event_id,
        user_id,
        session_id,
        event_name,
        properties as event_property,
        case
            when properties like '/%' then 'page_path'
            else 'action_name'
        end as property_type,
        created_at as event_timestamp
    from source
)

select * from final
