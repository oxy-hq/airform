with source as (
    select * from {{ source('raw', 'raw_events') }}
),
renamed as (
    select
        id as event_id
,        platform
,        event_type
,        device_type
,        country
,        properties
,        user_id
    from source
)
select * from renamed
