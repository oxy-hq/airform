with source as (
    select * from {{ source('raw', 'raw_events') }}
),
renamed as (
    select
        id as event_id
,        event_type
,        properties
,        user_id
,        session_id
,        country
,        created_at
    from source
)
select * from renamed
