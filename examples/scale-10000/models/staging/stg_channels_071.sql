with source as (
    select * from {{ source('raw', 'raw_channels') }}
),
renamed as (
    select
        id as channel_id
,        cost_per_impression
,        channel_name
,        channel_type
,        is_active
,        region
    from source
)
select * from renamed
