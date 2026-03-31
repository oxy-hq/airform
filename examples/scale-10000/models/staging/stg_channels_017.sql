with source as (
    select * from {{ source('raw', 'raw_channels') }}
),
renamed as (
    select
        id as channel_id
,        region
,        cost_per_click
,        is_active
,        channel_name
    from source
)
select * from renamed
