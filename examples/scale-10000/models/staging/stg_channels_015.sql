with source as (
    select * from {{ source('raw', 'raw_channels') }}
),
renamed as (
    select
        id as channel_id
,        channel_name
,        cost_per_impression
,        category
    from source
)
select * from renamed
