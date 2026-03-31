with source as (
    select * from {{ source('raw', 'raw_page_views') }}
),
renamed as (
    select
        id as page_view_id
,        user_id
,        viewed_at
,        is_exit
    from source
)
select * from renamed
