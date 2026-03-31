with source as (
    select * from {{ source('raw', 'raw_sessions') }}
),
renamed as (
    select
        id as session_id
,        platform
,        country
,        browser
,        ended_at
    from source
)
select * from renamed
