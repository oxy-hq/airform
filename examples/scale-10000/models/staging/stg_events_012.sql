with source as (
    select * from {{ source('raw', 'raw_events') }}
),
renamed as (
    select
        id as event_id
,        properties
,        device_type
,        country
,        session_id
,        created_at
    from source
)
select * from renamed
