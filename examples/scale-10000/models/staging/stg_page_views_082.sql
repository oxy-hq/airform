with source as (
    select * from {{ source('raw', 'raw_page_views') }}
),
renamed as (
    select
        id as page_view_id
,        session_id
,        page_url
,        is_exit
,        time_on_page
,        viewed_at
,        page_title
,        referrer
    from source
)
select * from renamed
