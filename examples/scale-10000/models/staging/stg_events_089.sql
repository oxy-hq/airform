with source as (
    select * from {{ source('raw', 'raw_events') }}
),
renamed as (
    select
        id as event_id
,        platform
,        created_at
,        session_id
    from source
)
select * from renamed
