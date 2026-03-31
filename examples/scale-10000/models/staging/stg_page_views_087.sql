with source as (
    select * from {{ source('raw', 'raw_page_views') }}
),
renamed as (
    select
        id as page_view_id
,        session_id
,        page_url
,        time_on_page
,        page_title
,        viewed_at
,        is_exit
,        device_type
    from source
)
select * from renamed
