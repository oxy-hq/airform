with source as (
    select * from {{ source('raw', 'raw_events') }}
),
renamed as (
    select
        id as event_id
,        platform
,        session_id
,        user_id
,        device_type
,        properties
    from source
)
select * from renamed
