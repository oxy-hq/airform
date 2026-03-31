with source as (
    select * from {{ source('raw', 'raw_channels') }}
),
renamed as (
    select
        id as channel_id
,        channel_type
,        channel_name
,        cost_per_click
,        cost_per_impression
,        priority
,        region
,        is_active
    from source
)
select * from renamed
