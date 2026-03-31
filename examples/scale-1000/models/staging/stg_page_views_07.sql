with source as (
    select * from {{ source('raw', 'raw_page_views') }}
),

renamed as (
    select
        id as page_view_id
,        page_title
,        referrer
,        time_on_page
,        viewed_at
,        page_url
,        is_exit
,        device_type
    from source
)

select * from renamed
