with source as (
    select * from {{ source('raw', 'raw_sessions') }}
),
renamed as (
    select
        id as session_id
,        ended_at
,        country
,        page_count
,        is_bounce
,        platform
,        browser
    from source
)
select * from renamed
