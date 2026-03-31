with source as (
    select * from {{ source('raw', 'raw_sessions') }}
),
renamed as (
    select
        id as session_id
,        country
,        ended_at
,        page_count
    from source
)
select * from renamed
