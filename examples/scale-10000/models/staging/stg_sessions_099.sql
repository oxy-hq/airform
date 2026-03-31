with source as (
    select * from {{ source('raw', 'raw_sessions') }}
),
renamed as (
    select
        id as session_id
,        page_count
,        platform
,        duration_seconds
,        started_at
,        ended_at
,        is_bounce
,        country
    from source
)
select * from renamed
