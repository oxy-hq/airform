with source as (
    select * from {{ source('raw', 'raw_channels') }}
),
renamed as (
    select
        id as channel_id
,        channel_name
,        priority
,        is_active
,        category
,        region
,        cost_per_impression
    from source
)
select * from renamed
