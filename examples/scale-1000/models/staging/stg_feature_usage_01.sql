with source as (
    select * from {{ source('raw', 'raw_feature_usage') }}
),

renamed as (
    select
        id as feature_usage_id
,        usage_count
,        feature_name
,        version
,        first_used_at
,        category
,        is_active
    from source
)

select * from renamed
