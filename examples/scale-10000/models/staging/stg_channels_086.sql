with source as (
    select * from {{ source('raw', 'raw_channels') }}
),
renamed as (
    select
        id as channel_id
,        cost_per_impression
,        priority
,        channel_name
,        region
,        channel_type
,        created_at
,        cost_per_click
    from source
)
select * from renamed
