with source as (
    select * from {{ source('raw', 'raw_events') }}
),
renamed as (
    select
        id as event_id
,        session_id
,        user_id
,        platform
,        device_type
    from source
)
select * from renamed
