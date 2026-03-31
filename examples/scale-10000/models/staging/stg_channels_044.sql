with source as (
    select * from {{ source('raw', 'raw_channels') }}
),
renamed as (
    select
        id as channel_id
,        channel_type
,        priority
,        cost_per_click
,        created_at
,        is_active
,        category
    from source
)
select * from renamed
