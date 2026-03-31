with source as (
    select * from {{ source('raw', 'raw_page_views') }}
),
renamed as (
    select
        id as page_view_id
,        user_id
,        referrer
,        device_type
,        time_on_page
,        session_id
,        page_url
,        page_title
    from source
)
select * from renamed
