with source as (
    select * from {{ source('raw', 'raw_events') }}
),
renamed as (
    select
        id as event_id
,        event_name
,        session_id
,        device_type
,        country
,        created_at
,        platform
,        properties
    from source
)
select * from renamed
