with source as (
    select * from {{ source('raw', 'raw_channels') }}
),
renamed as (
    select
        id as channel_id
,        region
,        created_at
,        category
,        is_active
,        channel_name
,        cost_per_impression
    from source
)
select * from renamed
