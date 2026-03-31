with source as (
    select * from {{ source('raw', 'raw_sessions') }}
),
renamed as (
    select
        id as session_id
,        is_bounce
,        user_id
,        started_at
,        page_count
,        ended_at
,        platform
,        country
    from source
)
select * from renamed
