with source as (
    select * from {{ source('raw', 'raw_events') }}
),
renamed as (
    select
        id as event_id
,        country
,        device_type
,        event_name
    from source
)
select * from renamed
