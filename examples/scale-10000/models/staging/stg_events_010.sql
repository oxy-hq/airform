with source as (
    select * from {{ source('raw', 'raw_events') }}
),
renamed as (
    select
        id as event_id
,        event_name
,        session_id
,        created_at
,        country
    from source
)
select * from renamed
