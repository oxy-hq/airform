with source as (
    select * from {{ source('raw', 'raw_page_views') }}
),
renamed as (
    select
        id as page_view_id
,        referrer
,        page_url
,        is_exit
,        device_type
,        session_id
,        time_on_page
,        page_title
    from source
)
select * from renamed
