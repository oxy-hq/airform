with source as (
    select * from {{ source('raw', 'raw_page_views') }}
),
renamed as (
    select
        id as page_view_id
,        page_url
,        viewed_at
,        referrer
,        is_exit
,        device_type
,        user_id
    from source
)
select * from renamed
