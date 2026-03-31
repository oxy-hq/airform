with source as (
    select * from {{ source('raw', 'raw_channels') }}
),

renamed as (
    select
        id as channel_id
,        channel_name
,        channel_type
,        cost_per_impression
,        created_at
,        is_active
    from source
)

select * from renamed
