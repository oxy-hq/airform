with source as (
    select * from {{ source('raw', 'raw_channels') }}
),
renamed as (
    select
        id as channel_id
,        channel_name
,        cost_per_impression
,        category
,        created_at
    from source
)
select * from renamed
