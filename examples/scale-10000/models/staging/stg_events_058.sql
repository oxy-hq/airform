with source as (
    select * from {{ source('raw', 'raw_events') }}
),
renamed as (
    select
        id as event_id
,        device_type
,        properties
,        country
,        session_id
,        created_at
,        event_type
    from source
)
select * from renamed
