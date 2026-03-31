with source as (
    select * from {{ source('raw', 'raw_page_views') }}
),
renamed as (
    select
        id as page_view_id
,        is_exit
,        device_type
,        viewed_at
,        time_on_page
,        page_url
,        page_title
    from source
)
select * from renamed
