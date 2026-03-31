with source as (
    select * from {{ source('raw', 'raw_channels') }}
),
renamed as (
    select
        id as channel_id
,        is_active
,        cost_per_click
,        channel_type
,        channel_name
,        priority
    from source
)
select * from renamed
