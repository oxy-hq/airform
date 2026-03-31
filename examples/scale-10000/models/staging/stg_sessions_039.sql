with source as (
    select * from {{ source('raw', 'raw_sessions') }}
),
renamed as (
    select
        id as session_id
,        is_bounce
,        browser
,        platform
,        user_id
    from source
)
select * from renamed
