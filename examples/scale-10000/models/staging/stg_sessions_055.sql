with source as (
    select * from {{ source('raw', 'raw_sessions') }}
),
renamed as (
    select
        id as session_id
,        page_count
,        duration_seconds
,        user_id
,        started_at
,        platform
,        browser
,        ended_at
    from source
)
select * from renamed
