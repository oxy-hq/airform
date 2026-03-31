with source as (
    select * from {{ source('raw', 'raw_page_views') }}
),
renamed as (
    select
        id as page_view_id
,        referrer
,        device_type
,        page_url
,        user_id
,        viewed_at
,        page_title
    from source
)
select * from renamed
