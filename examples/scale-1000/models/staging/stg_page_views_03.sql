with source as (
    select * from {{ source('raw', 'raw_page_views') }}
),

renamed as (
    select
        id as page_view_id
,        user_id
,        session_id
,        is_exit
,        referrer
,        viewed_at
    from source
)

select * from renamed
