with source as (
    select * from {{ source('raw', 'raw_events') }}
),
renamed as (
    select
        id as event_id
,        user_id
,        platform
,        country
,        event_name
,        properties
    from source
)
select * from renamed
