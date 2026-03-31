with source as (
    select * from {{ source('raw', 'raw_events') }}
),
renamed as (
    select
        id as event_id
,        created_at
,        event_name
,        properties
,        session_id
,        platform
,        device_type
,        country
    from source
)
select * from renamed
