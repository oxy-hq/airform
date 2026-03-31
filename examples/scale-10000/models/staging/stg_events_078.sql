with source as (
    select * from {{ source('raw', 'raw_events') }}
),
renamed as (
    select
        id as event_id
,        event_type
,        event_name
,        platform
,        device_type
,        properties
,        created_at
    from source
)
select * from renamed
