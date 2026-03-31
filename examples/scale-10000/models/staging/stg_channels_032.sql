with source as (
    select * from {{ source('raw', 'raw_channels') }}
),
renamed as (
    select
        id as channel_id
,        category
,        is_active
,        priority
,        region
,        created_at
,        channel_type
,        channel_name
    from source
)
select * from renamed
