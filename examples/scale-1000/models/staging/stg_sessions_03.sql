with source as (
    select * from {{ source('raw', 'raw_sessions') }}
),

renamed as (
    select
        id as session_id
,        country
,        platform
,        user_id
,        page_count
,        is_bounce
,        duration_seconds
,        ended_at
    from source
)

select * from renamed
