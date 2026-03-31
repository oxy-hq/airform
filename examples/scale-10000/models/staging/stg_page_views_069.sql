with source as (
    select * from {{ source('raw', 'raw_page_views') }}
),
renamed as (
    select
        id as page_view_id
,        page_title
,        device_type
,        is_exit
,        session_id
,        viewed_at
,        page_url
,        user_id
    from source
)
select * from renamed
