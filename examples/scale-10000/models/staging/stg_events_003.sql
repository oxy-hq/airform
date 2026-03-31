with source as (
    select * from {{ source('raw', 'raw_events') }}
),
renamed as (
    select
        id as event_id
,        properties
,        user_id
,        created_at
,        country
,        event_type
    from source
)
select * from renamed
