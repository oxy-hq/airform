with source as (
    select * from {{ source('raw', 'raw_sessions') }}
),
renamed as (
    select
        id as session_id
,        is_bounce
,        country
,        user_id
,        started_at
,        browser
    from source
)
select * from renamed
