with source as (
    select * from {{ source('raw', 'raw_page_views') }}
),
renamed as (
    select
        id as page_view_id
,        time_on_page
,        viewed_at
,        user_id
,        session_id
,        page_url
,        is_exit
    from source
)
select * from renamed
