with source as (
    select * from {{ source('raw', 'raw_sessions') }}
),
renamed as (
    select
        id as session_id
,        country
,        started_at
,        page_count
,        browser
,        user_id
,        is_bounce
    from source
)
select * from renamed
