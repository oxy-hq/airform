with source as (
    select * from {{ source('raw', 'raw_channels') }}
),
renamed as (
    select
        id as channel_id
,        channel_type
,        priority
,        cost_per_click
,        region
,        is_active
,        cost_per_impression
    from source
)
select * from renamed
