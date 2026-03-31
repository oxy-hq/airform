with source as (
    select * from {{ source('raw', 'raw_sessions') }}
),
renamed as (
    select
        id as session_id
,        page_count
,        browser
,        is_bounce
,        ended_at
,        platform
,        country
,        user_id
    from source
)
select * from renamed
