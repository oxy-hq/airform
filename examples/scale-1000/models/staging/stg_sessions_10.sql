with source as (
    select * from {{ source('raw', 'raw_sessions') }}
),

renamed as (
    select
        id as session_id
,        duration_seconds
,        is_bounce
,        ended_at
,        platform
,        user_id
,        page_count
,        country
    from source
)

select * from renamed
