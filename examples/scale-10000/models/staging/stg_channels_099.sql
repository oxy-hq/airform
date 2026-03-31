with source as (
    select * from {{ source('raw', 'raw_channels') }}
),
renamed as (
    select
        id as channel_id
,        region
,        channel_name
,        priority
    from source
)
select * from renamed
