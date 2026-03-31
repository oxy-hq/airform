with source as (
    select * from {{ source('raw', 'raw_sessions') }}
),
renamed as (
    select
        id as session_id
,        duration_seconds
,        is_bounce
,        user_id
,        country
    from source
)
select * from renamed
