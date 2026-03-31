with source as (
    select * from {{ source('raw', 'raw_sessions') }}
),
renamed as (
    select
        id as session_id
,        duration_seconds
,        country
,        user_id
,        ended_at
,        platform
,        started_at
,        page_count
    from source
)
select * from renamed
