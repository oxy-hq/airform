with source as (
    select * from {{ source('raw', 'raw_events') }}
),
renamed as (
    select
        id as event_id
,        country
,        event_name
,        event_type
,        device_type
,        created_at
,        user_id
,        properties
    from source
)
select * from renamed
