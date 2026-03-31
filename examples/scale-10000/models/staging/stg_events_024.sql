with source as (
    select * from {{ source('raw', 'raw_events') }}
),
renamed as (
    select
        id as event_id
,        platform
,        properties
,        event_name
,        created_at
,        country
,        event_type
,        user_id
    from source
)
select * from renamed
