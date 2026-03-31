with source as (
    select * from {{ source('raw', 'raw_feature_usage') }}
),

renamed as (
    select
        id as feature_usage_id
,        version
,        last_used_at
,        platform
,        is_active
    from source
)

select * from renamed
