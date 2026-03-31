with source as (
    select * from {{ source('raw', 'raw_page_views') }}
),
renamed as (
    select
        id as page_view_id
,        device_type
,        time_on_page
,        viewed_at
    from source
)
select * from renamed
