with source as (
    select * from {{ source('raw', 'raw_page_views') }}
),
renamed as (
    select
        id as page_view_id
,        page_title
,        user_id
,        time_on_page
,        session_id
,        referrer
,        device_type
,        is_exit
    from source
)
select * from renamed
