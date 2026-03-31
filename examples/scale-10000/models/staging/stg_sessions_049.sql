with source as (
    select * from {{ source('raw', 'raw_sessions') }}
),
renamed as (
    select
        id as session_id
,        ended_at
,        is_bounce
,        browser
,        platform
    from source
)
select * from renamed
