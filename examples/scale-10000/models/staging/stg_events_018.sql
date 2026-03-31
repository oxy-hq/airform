with source as (
    select * from {{ source('raw', 'raw_events') }}
),
renamed as (
    select
        id as event_id
,        event_type
,        properties
,        country
    from source
)
select * from renamed
