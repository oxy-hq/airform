with source as (
    select * from {{ source('raw', 'raw_events') }}
),

renamed as (
    select
        id as event_id
,        created_at
,        country
,        properties
,        session_id
,        event_name
,        platform
,        event_type
    from source
)

select * from renamed
