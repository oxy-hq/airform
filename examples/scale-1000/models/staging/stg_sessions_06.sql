with source as (
    select * from {{ source('raw', 'raw_sessions') }}
),

renamed as (
    select
        id as session_id
,        user_id
,        browser
,        country
,        started_at
,        is_bounce
    from source
)

select * from renamed
