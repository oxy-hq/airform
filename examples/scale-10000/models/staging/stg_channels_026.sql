with source as (
    select * from {{ source('raw', 'raw_channels') }}
),
renamed as (
    select
        id as channel_id
,        created_at
,        channel_type
,        category
,        channel_name
,        priority
,        region
,        cost_per_click
    from source
)
select * from renamed
