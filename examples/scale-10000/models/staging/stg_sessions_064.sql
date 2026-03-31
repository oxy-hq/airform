with source as (
    select * from {{ source('raw', 'raw_sessions') }}
),
renamed as (
    select
        id as session_id
,        country
,        is_bounce
,        duration_seconds
,        started_at
,        page_count
,        platform
,        ended_at
    from source
)
select * from renamed
