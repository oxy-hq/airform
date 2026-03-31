with source as (
    select * from {{ source('raw', 'raw_events') }}
),
renamed as (
    select
        id as event_id
,        created_at
,        properties
,        device_type
    from source
)
select * from renamed
