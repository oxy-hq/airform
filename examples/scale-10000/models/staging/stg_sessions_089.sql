with source as (
    select * from {{ source('raw', 'raw_sessions') }}
),
renamed as (
    select
        id as session_id
,        started_at
,        user_id
,        page_count
,        browser
,        platform
    from source
)
select * from renamed
