with source as (
    select * from {{ source('raw', 'raw_sessions') }}
),
renamed as (
    select
        id as session_id
,        duration_seconds
,        user_id
,        country
,        browser
,        is_bounce
    from source
)
select * from renamed
