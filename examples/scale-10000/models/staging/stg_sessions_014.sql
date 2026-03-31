with source as (
    select * from {{ source('raw', 'raw_sessions') }}
),
renamed as (
    select
        id as session_id
,        platform
,        started_at
,        user_id
,        ended_at
,        duration_seconds
    from source
)
select * from renamed
