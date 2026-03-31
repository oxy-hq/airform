with source as (
    select * from {{ source('raw', 'raw_sessions') }}
),

renamed as (
    select
        id as session_id,
        user_id,
        started_at,
        ended_at,
        device_type,
        browser,
        referrer,
        landing_page
    from source
)

select * from renamed
