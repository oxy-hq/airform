with source as (
    select * from {{ source('raw', 'raw_page_views') }}
),
renamed as (
    select
        id as page_view_id
,        referrer
,        device_type
,        is_exit
,        time_on_page
,        user_id
,        viewed_at
,        page_url
    from source
)
select * from renamed
