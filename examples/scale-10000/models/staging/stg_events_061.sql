with source as (
    select * from {{ source('raw', 'raw_events') }}
),
renamed as (
    select
        id as event_id
,        session_id
,        country
,        user_id
,        device_type
,        properties
,        created_at
,        event_name
    from source
)
select * from renamed
