with source as (
    select * from {{ source('raw', 'raw_sessions') }}
),
renamed as (
    select
        id as session_id
,        started_at
,        browser
,        page_count
,        platform
    from source
)
select * from renamed
