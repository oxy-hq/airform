with source as (
    select * from {{ source('raw', 'raw_sessions') }}
),
renamed as (
    select
        id as session_id
,        country
,        is_bounce
,        started_at
,        browser
,        platform
    from source
)
select * from renamed
