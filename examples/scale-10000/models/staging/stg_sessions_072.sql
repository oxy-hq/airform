with source as (
    select * from {{ source('raw', 'raw_sessions') }}
),
renamed as (
    select
        id as session_id
,        user_id
,        ended_at
,        duration_seconds
,        started_at
,        browser
,        country
    from source
)
select * from renamed
