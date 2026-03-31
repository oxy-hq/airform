with source as (
    select * from {{ source('raw', 'raw_events') }}
),

renamed as (
    select
        id as event_id
,        platform
,        properties
,        event_type
,        device_type
,        event_name
,        session_id
,        created_at
    from source
)

select * from renamed
