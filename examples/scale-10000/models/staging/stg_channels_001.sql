with source as (
    select * from {{ source('raw', 'raw_channels') }}
),
renamed as (
    select
        id as channel_id
,        created_at
,        region
,        channel_name
,        category
,        channel_type
    from source
)
select * from renamed
