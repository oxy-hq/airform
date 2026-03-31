with source as (
    select * from {{ source('raw', 'raw_sessions') }}
),
renamed as (
    select
        id as session_id
,        platform
,        is_bounce
,        ended_at
    from source
)
select * from renamed
