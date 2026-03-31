with source as (
    select * from {{ source('raw', 'raw_page_views') }}
),
renamed as (
    select
        id as page_view_id
,        session_id
,        user_id
,        time_on_page
,        is_exit
,        viewed_at
,        device_type
    from source
)
select * from renamed
