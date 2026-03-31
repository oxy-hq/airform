with source as (
    select * from {{ source('raw', 'raw_events') }}
),
renamed as (
    select
        id as event_id
,        country
,        event_name
,        session_id
,        properties
,        event_type
,        created_at
,        device_type
    from source
)
select * from renamed
