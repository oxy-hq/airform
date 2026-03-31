with source as (
    select * from {{ source('raw', 'raw_channels') }}
),
renamed as (
    select
        id as channel_id
,        channel_name
,        created_at
,        cost_per_impression
    from source
)
select * from renamed
