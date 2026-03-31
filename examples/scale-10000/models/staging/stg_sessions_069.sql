with source as (
    select * from {{ source('raw', 'raw_sessions') }}
),
renamed as (
    select
        id as session_id
,        started_at
,        page_count
,        ended_at
,        country
,        platform
    from source
)
select * from renamed
