with source as (
    select * from {{ source('raw', 'raw_channels') }}
),
renamed as (
    select
        id as channel_id
,        channel_type
,        is_active
,        priority
,        channel_name
,        cost_per_click
,        region
,        created_at
    from source
)
select * from renamed
