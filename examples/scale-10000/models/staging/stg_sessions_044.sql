with source as (
    select * from {{ source('raw', 'raw_sessions') }}
),
renamed as (
    select
        id as session_id
,        browser
,        platform
,        duration_seconds
,        user_id
,        started_at
,        is_bounce
    from source
)
select * from renamed
