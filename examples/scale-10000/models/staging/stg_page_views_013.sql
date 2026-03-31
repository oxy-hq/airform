with source as (
    select * from {{ source('raw', 'raw_page_views') }}
),
renamed as (
    select
        id as page_view_id
,        viewed_at
,        referrer
,        time_on_page
,        page_url
,        session_id
,        is_exit
,        device_type
    from source
)
select * from renamed
