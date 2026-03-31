with source as (
    select * from {{ source('raw', 'raw_page_views') }}
),
renamed as (
    select
        id as page_view_id
,        is_exit
,        page_title
,        device_type
,        time_on_page
,        user_id
,        page_url
,        session_id
    from source
)
select * from renamed
