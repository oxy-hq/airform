with source as (
    select * from {{ source('raw', 'raw_events') }}
),
renamed as (
    select
        id as event_id
,        properties
,        session_id
,        created_at
,        event_name
,        event_type
,        country
    from source
)
select * from renamed
