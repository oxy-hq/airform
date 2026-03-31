with source as (
    select * from {{ source('raw', 'raw_sessions') }}
),
renamed as (
    select
        id as session_id
,        page_count
,        country
,        duration_seconds
    from source
)
select * from renamed
