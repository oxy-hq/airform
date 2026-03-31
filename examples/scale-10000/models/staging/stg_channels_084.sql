with source as (
    select * from {{ source('raw', 'raw_channels') }}
),
renamed as (
    select
        id as channel_id
,        category
,        channel_type
,        created_at
    from source
)
select * from renamed
