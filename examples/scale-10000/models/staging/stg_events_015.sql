with source as (
    select * from {{ source('raw', 'raw_events') }}
),
renamed as (
    select
        id as event_id
,        event_type
,        created_at
,        device_type
,        country
,        user_id
    from source
)
select * from renamed
