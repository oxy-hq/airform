with source as (
    select * from {{ source('raw', 'raw_channels') }}
),
renamed as (
    select
        id as channel_id
,        created_at
,        priority
,        region
    from source
)
select * from renamed
