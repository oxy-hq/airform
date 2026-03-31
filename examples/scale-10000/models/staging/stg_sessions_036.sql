with source as (
    select * from {{ source('raw', 'raw_sessions') }}
),
renamed as (
    select
        id as session_id
,        country
,        platform
,        browser
,        duration_seconds
,        started_at
,        is_bounce
,        page_count
    from source
)
select * from renamed
