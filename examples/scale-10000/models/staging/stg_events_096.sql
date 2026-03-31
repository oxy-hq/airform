with source as (
    select * from {{ source('raw', 'raw_events') }}
),
renamed as (
    select
        id as event_id
,        device_type
,        event_type
,        country
,        created_at
,        event_name
,        session_id
    from source
)
select * from renamed
