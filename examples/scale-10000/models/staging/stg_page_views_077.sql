with source as (
    select * from {{ source('raw', 'raw_page_views') }}
),
renamed as (
    select
        id as page_view_id
,        page_title
,        user_id
,        referrer
,        device_type
,        is_exit
,        page_url
,        viewed_at
    from source
)
select * from renamed
