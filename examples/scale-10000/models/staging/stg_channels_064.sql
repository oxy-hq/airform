with source as (
    select * from {{ source('raw', 'raw_channels') }}
),
renamed as (
    select
        id as channel_id
,        priority
,        cost_per_click
,        category
,        region
,        is_active
,        channel_type
    from source
)
select * from renamed
