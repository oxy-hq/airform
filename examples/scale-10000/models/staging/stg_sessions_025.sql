with source as (
    select * from {{ source('raw', 'raw_sessions') }}
),
renamed as (
    select
        id as session_id
,        duration_seconds
,        ended_at
,        country
,        platform
,        page_count
,        started_at
,        is_bounce
    from source
)
select * from renamed
