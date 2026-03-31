with source as (
    select * from {{ source('raw', 'raw_channels') }}
),

renamed as (
    select
        id as channel_id
,        priority
,        cost_per_click
,        cost_per_impression
,        is_active
,        created_at
,        category
    from source
)

select * from renamed
