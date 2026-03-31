with source as (
    select * from {{ source('raw', 'raw_page_views') }}
),
renamed as (
    select
        id as page_view_id
,        page_url
,        device_type
,        viewed_at
,        is_exit
    from source
)
select * from renamed
