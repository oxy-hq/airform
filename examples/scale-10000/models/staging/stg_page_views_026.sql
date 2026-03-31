with source as (
    select * from {{ source('raw', 'raw_page_views') }}
),
renamed as (
    select
        id as page_view_id
,        device_type
,        user_id
,        is_exit
,        time_on_page
,        viewed_at
,        page_url
,        referrer
    from source
)
select * from renamed
