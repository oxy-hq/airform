with source as (
    select * from {{ source('raw', 'raw_sessions') }}
),
renamed as (
    select
        id as session_id
,        started_at
,        user_id
,        ended_at
,        country
,        page_count
,        platform
,        is_bounce
    from source
)
select * from renamed
