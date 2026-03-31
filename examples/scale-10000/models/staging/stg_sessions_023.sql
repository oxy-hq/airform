with source as (
    select * from {{ source('raw', 'raw_sessions') }}
),
renamed as (
    select
        id as session_id
,        duration_seconds
,        browser
,        started_at
,        page_count
,        country
,        is_bounce
,        platform
    from source
)
select * from renamed
