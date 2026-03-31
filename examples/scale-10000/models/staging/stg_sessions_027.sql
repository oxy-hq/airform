with source as (
    select * from {{ source('raw', 'raw_sessions') }}
),
renamed as (
    select
        id as session_id
,        started_at
,        ended_at
,        country
,        is_bounce
,        user_id
,        browser
,        platform
    from source
)
select * from renamed
