with source as (
    select * from {{ source('raw', 'raw_channels') }}
),
renamed as (
    select
        id as channel_id
,        cost_per_click
,        category
,        cost_per_impression
,        channel_type
,        channel_name
,        created_at
    from source
)
select * from renamed
