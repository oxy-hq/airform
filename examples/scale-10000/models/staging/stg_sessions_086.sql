with source as (
    select * from {{ source('raw', 'raw_sessions') }}
),
renamed as (
    select
        id as session_id
,        user_id
,        started_at
,        page_count
,        platform
,        ended_at
,        is_bounce
    from source
)
select * from renamed
