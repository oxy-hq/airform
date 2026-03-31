with source as (
    select * from {{ source('raw', 'raw_channels') }}
),
renamed as (
    select
        id as channel_id
,        cost_per_impression
,        priority
,        channel_name
,        category
,        cost_per_click
,        is_active
,        created_at
    from source
)
select * from renamed
