with source as (
    select * from {{ source('raw', 'raw_events') }}
),
renamed as (
    select
        id as event_id
,        user_id
,        session_id
,        event_type
,        created_at
    from source
)
select * from renamed
