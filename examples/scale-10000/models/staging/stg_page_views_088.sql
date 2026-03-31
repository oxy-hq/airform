with source as (
    select * from {{ source('raw', 'raw_page_views') }}
),
renamed as (
    select
        id as page_view_id
,        time_on_page
,        referrer
,        session_id
,        viewed_at
,        user_id
    from source
)
select * from renamed
