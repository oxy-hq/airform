with source as (
    select * from {{ source('raw', 'raw_events') }}
),
renamed as (
    select
        id as event_id
,        user_id
,        platform
,        event_name
,        device_type
,        created_at
,        properties
,        country
    from source
)
select * from renamed
