with source as (
    select * from {{ source('raw', 'raw_sessions') }}
),
renamed as (
    select
        id as session_id
,        started_at
,        is_bounce
,        country
,        page_count
,        platform
,        browser
    from source
)
select * from renamed
