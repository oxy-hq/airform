with source as (
    select * from {{ source('raw', 'raw_page_views') }}
),
renamed as (
    select
        id as page_view_id
,        time_on_page
,        page_url
,        device_type
,        is_exit
,        user_id
,        page_title
    from source
)
select * from renamed
