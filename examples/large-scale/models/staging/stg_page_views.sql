with source as (
    select * from {{ source('raw', 'raw_page_views') }}
),

renamed as (
    select
        id as page_view_id,
        user_id,
        session_id,
        page_url,
        page_title,
        referrer_url,
        viewed_at,
        time_on_page_seconds
    from source
)

select * from renamed
