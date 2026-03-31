with source as (
    select * from {{ source('raw', 'raw_page_views') }}
),
renamed as (
    select
        id as page_view_id
,        time_on_page
,        referrer
,        user_id
,        is_exit
,        page_url
,        device_type
,        session_id
    from source
)
select * from renamed
