with source as (
    select * from {{ source('raw', 'raw_sessions') }}
),
renamed as (
    select
        id as session_id
,        page_count
,        duration_seconds
,        is_bounce
,        started_at
,        platform
,        user_id
,        browser
    from source
)
select * from renamed
