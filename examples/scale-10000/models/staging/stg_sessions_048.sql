with source as (
    select * from {{ source('raw', 'raw_sessions') }}
),
renamed as (
    select
        id as session_id
,        is_bounce
,        browser
,        user_id
,        started_at
,        ended_at
,        platform
    from source
)
select * from renamed
