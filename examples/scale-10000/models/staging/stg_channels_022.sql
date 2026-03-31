with source as (
    select * from {{ source('raw', 'raw_channels') }}
),
renamed as (
    select
        id as channel_id
,        region
,        is_active
,        created_at
,        channel_type
    from source
)
select * from renamed
