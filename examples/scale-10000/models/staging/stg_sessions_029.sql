with source as (
    select * from {{ source('raw', 'raw_sessions') }}
),
renamed as (
    select
        id as session_id
,        started_at
,        ended_at
,        is_bounce
,        user_id
    from source
)
select * from renamed
