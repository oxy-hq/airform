with source as (
    select * from {{ source('raw', 'raw_sessions') }}
),
renamed as (
    select
        id as session_id
,        platform
,        country
,        is_bounce
,        user_id
,        ended_at
,        started_at
,        browser
    from source
)
select * from renamed
