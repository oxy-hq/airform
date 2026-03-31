with source as (
    select * from {{ source('raw', 'raw_events') }}
),
renamed as (
    select
        id as event_id
,        country
,        properties
,        user_id
,        event_name
,        event_type
,        platform
    from source
)
select * from renamed
