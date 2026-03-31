with source as (
    select * from {{ source('raw', 'raw_page_views') }}
),
renamed as (
    select
        id as page_view_id
,        is_exit
,        device_type
,        page_title
,        user_id
,        time_on_page
    from source
)
select * from renamed
