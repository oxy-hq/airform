with source as (
    select * from {{ source('raw', 'raw_events') }}
),
renamed as (
    select
        id as event_id
,        country
,        user_id
,        session_id
,        created_at
,        platform
    from source
)
select * from renamed
