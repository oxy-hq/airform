with source as (
    select * from {{ source('raw', 'raw_channels') }}
),
renamed as (
    select
        id as channel_id
,        cost_per_impression
,        is_active
,        priority
,        region
,        channel_name
,        category
    from source
)
select * from renamed
