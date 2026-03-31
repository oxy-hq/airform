with source as (
    select * from {{ source('raw', 'raw_channels') }}
),
renamed as (
    select
        id as channel_id
,        created_at
,        priority
,        cost_per_click
,        region
,        channel_name
,        channel_type
    from source
)
select * from renamed
