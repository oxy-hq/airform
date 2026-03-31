with source as (
    select * from {{ source('raw', 'raw_sessions') }}
),
renamed as (
    select
        id as session_id
,        ended_at
,        started_at
,        browser
,        platform
,        duration_seconds
,        user_id
,        country
    from source
)
select * from renamed
