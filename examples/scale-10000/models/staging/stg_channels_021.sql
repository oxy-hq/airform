with source as (
    select * from {{ source('raw', 'raw_channels') }}
),
renamed as (
    select
        id as channel_id
,        priority
,        created_at
,        region
,        category
,        channel_type
,        is_active
,        cost_per_click
    from source
)
select * from renamed
