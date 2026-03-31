with source as (
    select * from {{ source('raw', 'raw_channels') }}
),
renamed as (
    select
        id as channel_id
,        region
,        channel_name
,        channel_type
,        created_at
    from source
)
select * from renamed
