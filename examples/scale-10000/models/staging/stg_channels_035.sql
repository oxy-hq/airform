with source as (
    select * from {{ source('raw', 'raw_channels') }}
),
renamed as (
    select
        id as channel_id
,        region
,        is_active
,        channel_name
,        channel_type
,        priority
,        cost_per_impression
,        created_at
    from source
)
select * from renamed
