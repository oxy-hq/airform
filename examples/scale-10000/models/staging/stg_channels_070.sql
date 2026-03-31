with source as (
    select * from {{ source('raw', 'raw_channels') }}
),
renamed as (
    select
        id as channel_id
,        cost_per_click
,        channel_type
,        channel_name
,        region
    from source
)
select * from renamed
