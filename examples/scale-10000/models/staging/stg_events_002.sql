with source as (
    select * from {{ source('raw', 'raw_events') }}
),
renamed as (
    select
        id as event_id
,        device_type
,        session_id
,        platform
,        created_at
    from source
)
select * from renamed
