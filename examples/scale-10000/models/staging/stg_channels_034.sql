with source as (
    select * from {{ source('raw', 'raw_channels') }}
),
renamed as (
    select
        id as channel_id
,        channel_type
,        channel_name
,        region
,        category
,        cost_per_impression
,        is_active
,        cost_per_click
    from source
)
select * from renamed
