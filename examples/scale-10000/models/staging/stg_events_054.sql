with source as (
    select * from {{ source('raw', 'raw_events') }}
),
renamed as (
    select
        id as event_id
,        event_name
,        event_type
,        country
,        created_at
,        platform
    from source
)
select * from renamed
