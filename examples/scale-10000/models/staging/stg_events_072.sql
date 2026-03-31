with source as (
    select * from {{ source('raw', 'raw_events') }}
),
renamed as (
    select
        id as event_id
,        platform
,        session_id
,        device_type
,        country
,        user_id
,        event_name
,        created_at
    from source
)
select * from renamed
