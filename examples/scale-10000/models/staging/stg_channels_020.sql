with source as (
    select * from {{ source('raw', 'raw_channels') }}
),
renamed as (
    select
        id as channel_id
,        region
,        cost_per_click
,        priority
    from source
)
select * from renamed
