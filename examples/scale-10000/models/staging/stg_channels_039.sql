with source as (
    select * from {{ source('raw', 'raw_channels') }}
),
renamed as (
    select
        id as channel_id
,        cost_per_impression
,        channel_type
,        is_active
,        channel_name
,        priority
,        category
,        cost_per_click
    from source
)
select * from renamed
