with source as (
    select * from {{ source('raw', 'raw_sessions') }}
),

renamed as (
    select
        id as session_id
,        user_id
,        is_bounce
,        page_count
,        browser
,        duration_seconds
,        country
    from source
)

select * from renamed
