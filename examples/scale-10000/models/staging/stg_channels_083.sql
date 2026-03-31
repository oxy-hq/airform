with source as (
    select * from {{ source('raw', 'raw_channels') }}
),
renamed as (
    select
        id as channel_id
,        category
,        channel_type
,        region
,        channel_name
,        priority
,        is_active
,        created_at
    from source
)
select * from renamed
