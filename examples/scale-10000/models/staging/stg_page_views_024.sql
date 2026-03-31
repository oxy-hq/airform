with source as (
    select * from {{ source('raw', 'raw_page_views') }}
),
renamed as (
    select
        id as page_view_id
,        device_type
,        page_title
,        time_on_page
,        viewed_at
,        page_url
,        is_exit
,        referrer
    from source
)
select * from renamed
