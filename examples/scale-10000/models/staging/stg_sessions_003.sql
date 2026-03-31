with source as (
    select * from {{ source('raw', 'raw_sessions') }}
),
renamed as (
    select
        id as session_id
,        platform
,        duration_seconds
,        ended_at
,        browser
,        page_count
    from source
)
select * from renamed
