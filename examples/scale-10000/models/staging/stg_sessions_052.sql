with source as (
    select * from {{ source('raw', 'raw_sessions') }}
),
renamed as (
    select
        id as session_id
,        page_count
,        user_id
,        duration_seconds
,        browser
,        platform
,        country
,        ended_at
    from source
)
select * from renamed
