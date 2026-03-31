with source as (
    select * from {{ source('raw', 'raw_channels') }}
),
renamed as (
    select
        id as channel_id
,        region
,        channel_name
,        category
,        priority
,        cost_per_impression
,        channel_type
    from source
)
select * from renamed
