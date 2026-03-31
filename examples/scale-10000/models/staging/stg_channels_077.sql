with source as (
    select * from {{ source('raw', 'raw_channels') }}
),
renamed as (
    select
        id as channel_id
,        priority
,        channel_type
,        cost_per_click
,        category
,        channel_name
,        created_at
    from source
)
select * from renamed
