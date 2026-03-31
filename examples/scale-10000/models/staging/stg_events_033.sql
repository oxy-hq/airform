with source as (
    select * from {{ source('raw', 'raw_events') }}
),
renamed as (
    select
        id as event_id
,        event_type
,        event_name
,        device_type
,        country
    from source
)
select * from renamed
