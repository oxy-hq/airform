with source as (
    select * from {{ source('raw', 'raw_sessions') }}
),
renamed as (
    select
        id as session_id
,        is_bounce
,        started_at
,        country
,        browser
,        page_count
,        duration_seconds
,        ended_at
    from source
)
select * from renamed
