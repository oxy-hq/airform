with source as (
    select * from {{ source('raw', 'raw_channels') }}
),
renamed as (
    select
        id as channel_id
,        priority
,        channel_type
,        region
,        cost_per_impression
    from source
)
select * from renamed
