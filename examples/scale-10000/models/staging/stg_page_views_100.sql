with source as (
    select * from {{ source('raw', 'raw_page_views') }}
),
renamed as (
    select
        id as page_view_id
,        device_type
,        session_id
,        page_title
,        user_id
,        time_on_page
,        referrer
,        is_exit
    from source
)
select * from renamed
