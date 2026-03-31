with source as (
    select * from {{ source('raw', 'raw_sessions') }}
),
renamed as (
    select
        id as session_id
,        ended_at
,        started_at
,        user_id
,        platform
,        browser
    from source
)
select * from renamed
