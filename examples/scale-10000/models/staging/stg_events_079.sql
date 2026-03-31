with source as (
    select * from {{ source('raw', 'raw_events') }}
),
renamed as (
    select
        id as event_id
,        session_id
,        event_name
,        properties
,        platform
,        created_at
,        country
,        event_type
    from source
)
select * from renamed
