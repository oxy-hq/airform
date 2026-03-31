with source as (
    select * from {{ source('raw', 'raw_events') }}
),
renamed as (
    select
        id as event_id
,        country
,        session_id
,        event_name
    from source
)
select * from renamed
