with source as (
    select * from {{ source('raw', 'raw_channels') }}
),
renamed as (
    select
        id as channel_id
,        channel_name
,        cost_per_click
,        channel_type
,        region
,        created_at
    from source
)
select * from renamed
