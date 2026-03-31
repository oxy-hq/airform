with source as (
    select * from {{ source('raw', 'raw_events') }}
),
renamed as (
    select
        id as event_id
,        event_name
,        device_type
,        country
,        platform
,        properties
    from source
)
select * from renamed
