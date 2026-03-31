with source as (
    select * from {{ source('raw', 'raw_channels') }}
),
renamed as (
    select
        id as channel_id
,        created_at
,        channel_name
,        region
,        cost_per_click
    from source
)
select * from renamed
