with source as (
    select * from {{ source('raw', 'raw_sessions') }}
),
renamed as (
    select
        id as session_id
,        duration_seconds
,        is_bounce
,        page_count
,        browser
,        ended_at
,        country
,        platform
    from source
)
select * from renamed
