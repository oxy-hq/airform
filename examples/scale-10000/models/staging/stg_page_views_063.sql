with source as (
    select * from {{ source('raw', 'raw_page_views') }}
),
renamed as (
    select
        id as page_view_id
,        referrer
,        session_id
,        time_on_page
,        is_exit
,        device_type
    from source
)
select * from renamed
