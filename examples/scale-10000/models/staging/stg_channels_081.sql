with source as (
    select * from {{ source('raw', 'raw_channels') }}
),
renamed as (
    select
        id as channel_id
,        cost_per_click
,        cost_per_impression
,        priority
,        created_at
,        channel_name
    from source
)
select * from renamed
