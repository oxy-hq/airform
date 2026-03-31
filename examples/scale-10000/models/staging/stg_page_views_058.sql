with source as (
    select * from {{ source('raw', 'raw_page_views') }}
),
renamed as (
    select
        id as page_view_id
,        viewed_at
,        user_id
,        session_id
,        referrer
,        time_on_page
,        page_url
    from source
)
select * from renamed
