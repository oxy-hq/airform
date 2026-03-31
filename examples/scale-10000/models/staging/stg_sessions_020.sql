with source as (
    select * from {{ source('raw', 'raw_sessions') }}
),
renamed as (
    select
        id as session_id
,        duration_seconds
,        page_count
,        browser
,        user_id
,        ended_at
    from source
)
select * from renamed
