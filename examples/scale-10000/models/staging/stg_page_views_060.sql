with source as (
    select * from {{ source('raw', 'raw_page_views') }}
),
renamed as (
    select
        id as page_view_id
,        viewed_at
,        page_url
,        time_on_page
,        device_type
,        page_title
,        session_id
    from source
)
select * from renamed
