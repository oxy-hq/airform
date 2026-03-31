with source as (
    select * from {{ source('raw', 'raw_page_views') }}
),
renamed as (
    select
        id as page_view_id
,        time_on_page
,        user_id
,        is_exit
,        viewed_at
,        referrer
,        device_type
    from source
)
select * from renamed
