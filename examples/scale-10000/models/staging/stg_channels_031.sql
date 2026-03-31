with source as (
    select * from {{ source('raw', 'raw_channels') }}
),
renamed as (
    select
        id as channel_id
,        created_at
,        is_active
,        priority
    from source
)
select * from renamed
