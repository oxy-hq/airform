with source as (
    select * from {{ source('raw', 'raw_page_views') }}
),
renamed as (
    select
        id as page_view_id
,        user_id
,        is_exit
,        time_on_page
,        viewed_at
,        page_title
,        page_url
    from source
)
select * from renamed
