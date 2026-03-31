with source as (
    select * from {{ source('raw', 'raw_sessions') }}
),
renamed as (
    select
        id as session_id
,        started_at
,        page_count
,        browser
,        duration_seconds
    from source
)
select * from renamed
