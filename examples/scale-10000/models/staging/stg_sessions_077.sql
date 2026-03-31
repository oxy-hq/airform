with source as (
    select * from {{ source('raw', 'raw_sessions') }}
),
renamed as (
    select
        id as session_id
,        user_id
,        page_count
,        duration_seconds
,        is_bounce
,        browser
    from source
)
select * from renamed
