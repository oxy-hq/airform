with source as (
    select * from {{ source('raw', 'raw_sessions') }}
),
renamed as (
    select
        id as session_id
,        platform
,        country
,        duration_seconds
,        is_bounce
,        started_at
    from source
)
select * from renamed
