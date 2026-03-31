with source as (
    select * from {{ source('raw', 'raw_page_views') }}
),
renamed as (
    select
        id as page_view_id
,        device_type
,        user_id
,        viewed_at
,        referrer
,        page_url
,        time_on_page
    from source
)
select * from renamed
