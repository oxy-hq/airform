with source as (
    select * from {{ source('raw', 'raw_page_views') }}
),
renamed as (
    select
        id as page_view_id
,        device_type
,        session_id
,        is_exit
,        page_url
,        referrer
,        time_on_page
,        page_title
    from source
)
select * from renamed
