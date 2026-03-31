with source as (
    select * from {{ source('raw', 'raw_page_views') }}
),
renamed as (
    select
        id as page_view_id
,        session_id
,        user_id
,        is_exit
    from source
)
select * from renamed
