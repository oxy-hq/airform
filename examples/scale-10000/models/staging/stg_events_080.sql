with source as (
    select * from {{ source('raw', 'raw_events') }}
),
renamed as (
    select
        id as event_id
,        session_id
,        device_type
,        created_at
,        country
,        platform
,        event_name
,        properties
    from source
)
select * from renamed
