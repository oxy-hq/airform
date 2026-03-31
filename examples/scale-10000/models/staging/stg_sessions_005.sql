with source as (
    select * from {{ source('raw', 'raw_sessions') }}
),
renamed as (
    select
        id as session_id
,        country
,        ended_at
,        duration_seconds
,        user_id
,        started_at
,        page_count
,        is_bounce
    from source
)
select * from renamed
