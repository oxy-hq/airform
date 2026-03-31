with source as (
    select * from {{ source('raw', 'raw_sessions') }}
),
renamed as (
    select
        id as session_id
,        user_id
,        page_count
,        started_at
,        is_bounce
,        ended_at
,        browser
,        country
    from source
)
select * from renamed
