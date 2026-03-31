with source as (
    select * from {{ source('raw', 'raw_sessions') }}
),
renamed as (
    select
        id as session_id
,        browser
,        user_id
,        started_at
,        ended_at
,        duration_seconds
,        page_count
,        is_bounce
    from source
)
select * from renamed
