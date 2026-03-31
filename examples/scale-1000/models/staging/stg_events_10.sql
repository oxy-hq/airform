with source as (
    select * from {{ source('raw', 'raw_events') }}
),

renamed as (
    select
        id as event_id
,        country
,        event_name
,        properties
,        session_id
,        user_id
,        platform
,        created_at
    from source
)

select * from renamed
