with source as (
    select * from {{ source('raw', 'raw_sessions') }}
),
renamed as (
    select
        id as session_id
,        ended_at
,        started_at
,        platform
,        is_bounce
,        browser
,        duration_seconds
    from source
)
select * from renamed
