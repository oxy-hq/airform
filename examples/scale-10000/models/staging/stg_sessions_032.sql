with source as (
    select * from {{ source('raw', 'raw_sessions') }}
),
renamed as (
    select
        id as session_id
,        country
,        platform
,        started_at
,        duration_seconds
,        is_bounce
,        page_count
,        user_id
    from source
)
select * from renamed
