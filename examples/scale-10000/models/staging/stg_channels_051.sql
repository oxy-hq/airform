with source as (
    select * from {{ source('raw', 'raw_channels') }}
),
renamed as (
    select
        id as channel_id
,        channel_type
,        channel_name
,        is_active
,        region
    from source
)
select * from renamed
