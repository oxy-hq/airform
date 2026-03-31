with source as (
    select * from {{ source('raw', 'raw_events') }}
),
renamed as (
    select
        id as event_id
,        device_type
,        event_name
,        platform
,        country
,        session_id
,        properties
,        created_at
    from source
)
select * from renamed
