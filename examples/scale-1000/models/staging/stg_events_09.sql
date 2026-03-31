with source as (
    select * from {{ source('raw', 'raw_events') }}
),

renamed as (
    select
        id as event_id
,        country
,        event_name
,        session_id
,        device_type
,        event_type
,        properties
    from source
)

select * from renamed
