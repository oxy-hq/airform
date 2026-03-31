with source as (
    select * from {{ source('raw', 'raw_page_views') }}
),
renamed as (
    select
        id as page_view_id
,        page_title
,        page_url
,        session_id
    from source
)
select * from renamed
