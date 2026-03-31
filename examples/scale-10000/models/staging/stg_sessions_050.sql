with source as (
    select * from {{ source('raw', 'raw_sessions') }}
),
renamed as (
    select
        id as session_id
,        browser
,        page_count
,        ended_at
    from source
)
select * from renamed
