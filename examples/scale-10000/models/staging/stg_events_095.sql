with source as (
    select * from {{ source('raw', 'raw_events') }}
),
renamed as (
    select
        id as event_id
,        device_type
,        created_at
,        event_type
,        user_id
,        country
    from source
)
select * from renamed
