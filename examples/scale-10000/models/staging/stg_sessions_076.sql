with source as (
    select * from {{ source('raw', 'raw_sessions') }}
),
renamed as (
    select
        id as session_id
,        ended_at
,        browser
,        started_at
,        page_count
,        user_id
,        is_bounce
,        duration_seconds
    from source
)
select * from renamed
