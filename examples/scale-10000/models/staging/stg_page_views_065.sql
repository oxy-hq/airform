with source as (
    select * from {{ source('raw', 'raw_page_views') }}
),
renamed as (
    select
        id as page_view_id
,        page_url
,        session_id
,        page_title
,        time_on_page
    from source
)
select * from renamed
