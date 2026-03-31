with source as (
    select * from {{ source('raw', 'raw_sessions') }}
),

renamed as (
    select
        id as session_id
,        is_bounce
,        page_count
,        country
    from source
)

select * from renamed
