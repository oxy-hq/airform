with source as (
    select * from {{ source('raw', 'raw_sessions') }}
),
renamed as (
    select
        id as session_id
,        user_id
,        duration_seconds
,        platform
,        ended_at
    from source
)
select * from renamed
