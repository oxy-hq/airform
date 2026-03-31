with source as (
    select * from {{ source('raw', 'raw_sessions') }}
),
renamed as (
    select
        id as session_id
,        platform
,        started_at
,        page_count
,        is_bounce
,        duration_seconds
,        country
    from source
)
select * from renamed
