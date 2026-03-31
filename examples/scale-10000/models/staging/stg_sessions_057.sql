with source as (
    select * from {{ source('raw', 'raw_sessions') }}
),
renamed as (
    select
        id as session_id
,        page_count
,        platform
,        user_id
,        browser
,        country
,        duration_seconds
,        is_bounce
    from source
)
select * from renamed
