with source as (
    select * from {{ source('raw', 'raw_page_views') }}
),
renamed as (
    select
        id as page_view_id
,        user_id
,        page_url
,        viewed_at
,        page_title
,        is_exit
,        session_id
    from source
)
select * from renamed
