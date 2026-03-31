with source as (
    select * from {{ source('raw', 'raw_channels') }}
),
renamed as (
    select
        id as channel_id
,        category
,        cost_per_impression
,        priority
,        region
,        created_at
,        cost_per_click
    from source
)
select * from renamed
