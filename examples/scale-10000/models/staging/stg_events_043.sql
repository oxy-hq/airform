with source as (
    select * from {{ source('raw', 'raw_events') }}
),
renamed as (
    select
        id as event_id
,        platform
,        country
,        event_type
,        session_id
    from source
)
select * from renamed
