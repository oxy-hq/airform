with source as (
    select * from {{ source('raw', 'raw_page_views') }}
),
renamed as (
    select
        id as page_view_id
,        referrer
,        page_url
,        session_id
,        user_id
,        page_title
,        viewed_at
    from source
)
select * from renamed
