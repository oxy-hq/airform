with source as (
    select * from {{ source('raw', 'raw_events') }}
),
renamed as (
    select
        id as event_id
,        event_name
,        country
,        session_id
,        user_id
,        event_type
    from source
)
select * from renamed
