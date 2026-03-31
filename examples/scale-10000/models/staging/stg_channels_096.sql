with source as (
    select * from {{ source('raw', 'raw_channels') }}
),
renamed as (
    select
        id as channel_id
,        category
,        created_at
,        cost_per_impression
,        region
,        priority
    from source
)
select * from renamed
