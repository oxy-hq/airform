with source as (
    select * from {{ source('raw', 'raw_sessions') }}
),
renamed as (
    select
        id as session_id
,        user_id
,        ended_at
,        browser
,        is_bounce
,        page_count
    from source
)
select * from renamed
