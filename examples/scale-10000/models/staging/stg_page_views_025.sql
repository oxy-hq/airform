with source as (
    select * from {{ source('raw', 'raw_page_views') }}
),
renamed as (
    select
        id as page_view_id
,        time_on_page
,        session_id
,        device_type
,        viewed_at
,        page_title
,        page_url
,        referrer
    from source
)
select * from renamed
