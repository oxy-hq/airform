with source as (
    select * from {{ source('raw', 'raw_events') }}
),
renamed as (
    select
        id as event_id
,        event_name
,        event_type
,        properties
,        country
,        created_at
,        device_type
,        session_id
    from source
)
select * from renamed
