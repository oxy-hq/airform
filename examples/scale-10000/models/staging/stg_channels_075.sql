with source as (
    select * from {{ source('raw', 'raw_channels') }}
),
renamed as (
    select
        id as channel_id
,        cost_per_click
,        region
,        priority
,        channel_type
,        is_active
    from source
)
select * from renamed
