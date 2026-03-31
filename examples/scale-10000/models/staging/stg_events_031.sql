with source as (
    select * from {{ source('raw', 'raw_events') }}
),
renamed as (
    select
        id as event_id
,        event_type
,        platform
,        session_id
,        device_type
,        properties
    from source
)
select * from renamed
