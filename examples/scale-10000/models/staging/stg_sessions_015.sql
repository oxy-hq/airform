with source as (
    select * from {{ source('raw', 'raw_sessions') }}
),
renamed as (
    select
        id as session_id
,        browser
,        started_at
,        ended_at
,        duration_seconds
    from source
)
select * from renamed
