with source as (
    select * from {{ source('raw', 'raw_events') }}
),
renamed as (
    select
        id as event_id
,        platform
,        event_name
,        event_type
,        user_id
,        device_type
,        properties
    from source
)
select * from renamed
