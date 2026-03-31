with source as (
    select * from {{ source('raw', 'raw_channels') }}
),
renamed as (
    select
        id as channel_id
,        category
,        region
,        cost_per_impression
,        is_active
,        created_at
    from source
)
select * from renamed
