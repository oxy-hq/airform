with source as (
    select * from {{ source('raw', 'raw_page_views') }}
),

renamed as (
    select
        id as page_view_id
,        referrer
,        is_exit
,        viewed_at
,        page_title
,        session_id
,        device_type
    from source
)

select * from renamed
