with source as (
    select * from {{ source('raw', 'raw_events') }}
),
renamed as (
    select
        id as event_id
,        session_id
,        properties
,        event_name
,        user_id
,        created_at
    from source
)
select * from renamed
