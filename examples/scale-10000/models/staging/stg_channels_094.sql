with source as (
    select * from {{ source('raw', 'raw_channels') }}
),
renamed as (
    select
        id as channel_id
,        category
,        priority
,        channel_name
,        region
,        channel_type
,        cost_per_impression
    from source
)
select * from renamed
