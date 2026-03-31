with source as (
    select * from {{ source('raw', 'raw_sessions') }}
),
renamed as (
    select
        id as session_id
,        is_bounce
,        user_id
,        page_count
,        country
,        duration_seconds
,        browser
,        platform
    from source
)
select * from renamed
