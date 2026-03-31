with source as (
    select * from {{ source('raw', 'raw_channels') }}
),
renamed as (
    select
        id as channel_id
,        created_at
,        is_active
,        channel_name
,        channel_type
,        cost_per_impression
,        priority
    from source
)
select * from renamed
