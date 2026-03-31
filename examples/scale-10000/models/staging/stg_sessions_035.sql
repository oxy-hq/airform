with source as (
    select * from {{ source('raw', 'raw_sessions') }}
),
renamed as (
    select
        id as session_id
,        duration_seconds
,        started_at
,        country
,        is_bounce
    from source
)
select * from renamed
