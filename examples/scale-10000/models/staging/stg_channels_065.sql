with source as (
    select * from {{ source('raw', 'raw_channels') }}
),
renamed as (
    select
        id as channel_id
,        is_active
,        cost_per_click
,        channel_name
,        category
,        created_at
,        channel_type
    from source
)
select * from renamed
