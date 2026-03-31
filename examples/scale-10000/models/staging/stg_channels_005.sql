with source as (
    select * from {{ source('raw', 'raw_channels') }}
),
renamed as (
    select
        id as channel_id
,        cost_per_click
,        cost_per_impression
,        is_active
,        created_at
,        channel_name
,        category
,        priority
    from source
)
select * from renamed
