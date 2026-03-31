with source as (
    select * from {{ source('raw', 'raw_page_views') }}
),
renamed as (
    select
        id as page_view_id
,        referrer
,        time_on_page
,        session_id
,        page_url
,        device_type
,        user_id
    from source
)
select * from renamed
