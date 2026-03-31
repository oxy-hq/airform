with source as (
    select * from {{ source('raw', 'raw_feature_usage') }}
),

renamed as (
    select
        id as feature_usage_id
,        is_active
,        platform
,        version
,        usage_count
,        first_used_at
,        category
    from source
)

select * from renamed
