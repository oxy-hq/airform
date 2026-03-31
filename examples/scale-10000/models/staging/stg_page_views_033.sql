with source as (
    select * from {{ source('raw', 'raw_page_views') }}
),
renamed as (
    select
        id as page_view_id
,        session_id
,        viewed_at
,        page_title
,        is_exit
,        user_id
,        time_on_page
,        device_type
    from source
)
select * from renamed
