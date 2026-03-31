with source as (
    select * from {{ source('raw', 'raw_sessions') }}
),
renamed as (
    select
        id as session_id
,        platform
,        user_id
,        country
,        ended_at
,        is_bounce
,        page_count
,        started_at
    from source
)
select * from renamed
