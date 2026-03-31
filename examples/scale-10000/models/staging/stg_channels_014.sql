with source as (
    select * from {{ source('raw', 'raw_channels') }}
),
renamed as (
    select
        id as channel_id
,        channel_name
,        created_at
,        region
,        channel_type
,        cost_per_click
    from source
)
select * from renamed
