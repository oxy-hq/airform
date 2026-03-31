with source as (
    select * from {{ source('raw', 'raw_channels') }}
),

renamed as (
    select
        id as channel_id
,        channel_name
,        channel_type
,        region
,        category
,        created_at
,        cost_per_click
    from source
)

select * from renamed
