with source as (
    select * from {{ source('raw', 'raw_page_views') }}
),
renamed as (
    select
        id as page_view_id
,        page_url
,        time_on_page
,        viewed_at
,        user_id
,        page_title
,        device_type
    from source
)
select * from renamed
