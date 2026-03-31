with source as (
    select * from {{ source('raw', 'raw_events') }}
),
renamed as (
    select
        id as event_id
,        session_id
,        country
,        created_at
,        platform
,        user_id
    from source
)
select * from renamed
