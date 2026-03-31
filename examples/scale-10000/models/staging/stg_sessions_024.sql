with source as (
    select * from {{ source('raw', 'raw_sessions') }}
),
renamed as (
    select
        id as session_id
,        platform
,        country
,        page_count
,        started_at
,        is_bounce
,        browser
,        ended_at
    from source
)
select * from renamed
