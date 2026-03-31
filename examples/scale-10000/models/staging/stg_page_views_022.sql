with source as (
    select * from {{ source('raw', 'raw_page_views') }}
),
renamed as (
    select
        id as page_view_id
,        referrer
,        page_url
,        page_title
,        viewed_at
,        is_exit
,        time_on_page
,        user_id
    from source
)
select * from renamed
