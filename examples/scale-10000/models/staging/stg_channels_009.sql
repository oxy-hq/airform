with source as (
    select * from {{ source('raw', 'raw_channels') }}
),
renamed as (
    select
        id as channel_id
,        region
,        priority
,        cost_per_click
,        is_active
,        channel_type
,        category
,        channel_name
    from source
)
select * from renamed
