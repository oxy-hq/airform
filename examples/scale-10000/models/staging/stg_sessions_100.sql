with source as (
    select * from {{ source('raw', 'raw_sessions') }}
),
renamed as (
    select
        id as session_id
,        user_id
,        started_at
,        duration_seconds
,        is_bounce
,        ended_at
,        browser
    from source
)
select * from renamed
