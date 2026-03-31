with source as (
    select * from {{ source('raw', 'raw_sessions') }}
),
renamed as (
    select
        id as session_id
,        is_bounce
,        page_count
,        started_at
,        user_id
    from source
)
select * from renamed
