with source as (
    select * from {{ source('raw', 'raw_page_views') }}
),

renamed as (
    select
        id as page_view_id
,        referrer
,        user_id
,        page_url
,        device_type
    from source
)

select * from renamed
