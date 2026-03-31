with source as (
    select * from {{ source('raw', 'raw_page_views') }}
),
renamed as (
    select
        id as page_view_id
,        user_id
,        device_type
,        page_url
,        is_exit
,        referrer
,        viewed_at
,        session_id
    from source
)
select * from renamed
