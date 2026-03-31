with source as (
    select * from {{ source('raw', 'raw_channels') }}
),
renamed as (
    select
        id as channel_id
,        is_active
,        category
,        priority
,        cost_per_click
,        cost_per_impression
,        region
    from source
)
select * from renamed
