with source as (
    select * from {{ source('raw', 'raw_events') }}
),
renamed as (
    select
        id as event_id
,        session_id
,        platform
,        event_name
,        created_at
    from source
)
select * from renamed
