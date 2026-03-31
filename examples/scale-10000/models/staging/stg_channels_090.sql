with source as (
    select * from {{ source('raw', 'raw_channels') }}
),
renamed as (
    select
        id as channel_id
,        channel_type
,        region
,        cost_per_click
,        created_at
,        is_active
    from source
)
select * from renamed
