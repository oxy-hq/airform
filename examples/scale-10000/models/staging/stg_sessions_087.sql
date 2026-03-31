with source as (
    select * from {{ source('raw', 'raw_sessions') }}
),
renamed as (
    select
        id as session_id
,        page_count
,        duration_seconds
,        ended_at
,        started_at
,        platform
,        browser
,        is_bounce
    from source
)
select * from renamed
