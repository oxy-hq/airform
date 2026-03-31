with source as (
    select * from {{ source('raw', 'raw_channels') }}
),
renamed as (
    select
        id as channel_id
,        cost_per_impression
,        is_active
,        created_at
,        region
    from source
)
select * from renamed
