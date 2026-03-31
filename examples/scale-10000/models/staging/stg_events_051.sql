with source as (
    select * from {{ source('raw', 'raw_events') }}
),
renamed as (
    select
        id as event_id
,        country
,        event_name
,        device_type
    from source
)
select * from renamed
