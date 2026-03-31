with source as (
    select * from {{ source('raw', 'raw_sessions') }}
),
renamed as (
    select
        id as session_id
,        user_id
,        ended_at
,        started_at
,        country
,        platform
,        duration_seconds
    from source
)
select * from renamed
