with source as (
    select * from {{ source('raw', 'raw_events') }}
),
renamed as (
    select
        id as event_id
,        device_type
,        platform
,        event_type
,        country
    from source
)
select * from renamed
