with source as (
    select * from {{ source('raw', 'raw_channels') }}
),
renamed as (
    select
        id as channel_id
,        is_active
,        cost_per_impression
,        category
,        priority
,        channel_type
,        created_at
    from source
)
select * from renamed
