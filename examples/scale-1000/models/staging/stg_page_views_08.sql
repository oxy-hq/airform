with source as (
    select * from {{ source('raw', 'raw_page_views') }}
),

renamed as (
    select
        id as page_view_id
,        user_id
,        time_on_page
,        session_id
,        referrer
    from source
)

select * from renamed
