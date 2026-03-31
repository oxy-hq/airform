with source as (
    select * from {{ source('raw', 'raw_channels') }}
),
renamed as (
    select
        id as channel_id
,        channel_type
,        is_active
,        cost_per_impression
,        channel_name
,        cost_per_click
,        region
    from source
)
select * from renamed
