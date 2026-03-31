with source as (
    select * from {{ source('raw', 'raw_events') }}
),
renamed as (
    select
        id as event_id
,        country
,        device_type
,        user_id
,        created_at
,        properties
,        event_name
,        event_type
    from source
)
select * from renamed
