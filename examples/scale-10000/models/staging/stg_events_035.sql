with source as (
    select * from {{ source('raw', 'raw_events') }}
),
renamed as (
    select
        id as event_id
,        country
,        created_at
,        event_name
,        user_id
,        event_type
,        session_id
,        platform
    from source
)
select * from renamed
