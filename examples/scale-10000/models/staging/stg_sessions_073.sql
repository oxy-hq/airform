with source as (
    select * from {{ source('raw', 'raw_sessions') }}
),
renamed as (
    select
        id as session_id
,        browser
,        user_id
,        is_bounce
,        page_count
,        ended_at
,        platform
    from source
)
select * from renamed
