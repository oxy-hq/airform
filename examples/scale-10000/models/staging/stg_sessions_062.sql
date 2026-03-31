with source as (
    select * from {{ source('raw', 'raw_sessions') }}
),
renamed as (
    select
        id as session_id
,        duration_seconds
,        is_bounce
,        page_count
,        user_id
,        platform
,        browser
,        started_at
    from source
)
select * from renamed
