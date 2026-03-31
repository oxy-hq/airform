with source as (
    select * from {{ source('raw', 'raw_sessions') }}
),
renamed as (
    select
        id as session_id
,        page_count
,        ended_at
,        platform
,        country
,        is_bounce
    from source
)
select * from renamed
