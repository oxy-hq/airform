with source as (
    select * from {{ source('raw', 'raw_events') }}
),
renamed as (
    select
        id as event_id
,        user_id
,        properties
,        country
,        device_type
,        event_name
,        event_type
    from source
)
select * from renamed
