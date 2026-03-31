with source as (
    select * from {{ source('raw', 'raw_page_views') }}
),

renamed as (
    select
        id as page_view_id
,        user_id
,        device_type
,        referrer
,        page_title
    from source
)

select * from renamed
