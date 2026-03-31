with source as (
    select * from {{ source('raw', 'raw_channels') }}
),
renamed as (
    select
        id as channel_id
,        is_active
,        cost_per_click
,        channel_name
,        category
,        cost_per_impression
    from source
)
select * from renamed
