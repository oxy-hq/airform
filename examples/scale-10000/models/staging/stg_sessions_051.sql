with source as (
    select * from {{ source('raw', 'raw_sessions') }}
),
renamed as (
    select
        id as session_id
,        page_count
,        ended_at
,        user_id
,        started_at
,        platform
,        browser
    from source
)
select * from renamed
