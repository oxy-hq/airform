with source as (
    select * from {{ source('raw', 'raw_events') }}
),
renamed as (
    select
        id as event_id
,        platform
,        device_type
,        event_type
,        country
,        created_at
,        properties
,        user_id
    from source
)
select * from renamed
