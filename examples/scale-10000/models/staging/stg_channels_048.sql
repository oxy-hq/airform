with source as (
    select * from {{ source('raw', 'raw_channels') }}
),
renamed as (
    select
        id as channel_id
,        category
,        priority
,        cost_per_click
,        region
,        channel_type
,        created_at
,        channel_name
    from source
)
select * from renamed
