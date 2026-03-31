with source as (
    select * from {{ source('raw', 'raw_sessions') }}
),
renamed as (
    select
        id as session_id
,        ended_at
,        platform
,        user_id
,        page_count
    from source
)
select * from renamed
