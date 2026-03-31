with source as (
    select * from {{ source('raw', 'raw_channels') }}
),
renamed as (
    select
        id as channel_id
,        region
,        channel_type
,        category
,        created_at
,        cost_per_impression
,        channel_name
,        priority
    from source
)
select * from renamed
