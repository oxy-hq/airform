with source as (
    select * from {{ source('raw', 'raw_channels') }}
),
renamed as (
    select
        id as channel_id
,        priority
,        cost_per_click
,        is_active
,        channel_type
,        region
,        category
    from source
)
select * from renamed
