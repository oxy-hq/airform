with source as (
    select * from {{ source('raw', 'raw_channels') }}
),
renamed as (
    select
        id as channel_id
,        is_active
,        category
,        channel_type
,        cost_per_impression
,        region
,        priority
,        created_at
    from source
)
select * from renamed
