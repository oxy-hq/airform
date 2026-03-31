with source as (
    select * from {{ source('raw', 'raw_channels') }}
),
renamed as (
    select
        id as channel_id
,        is_active
,        priority
,        channel_type
,        cost_per_click
,        created_at
,        region
    from source
)
select * from renamed
