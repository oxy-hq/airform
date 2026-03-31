with source as (
    select * from {{ source('raw', 'raw_page_views') }}
),
renamed as (
    select
        id as page_view_id
,        is_exit
,        time_on_page
,        session_id
,        page_title
,        page_url
    from source
)
select * from renamed
