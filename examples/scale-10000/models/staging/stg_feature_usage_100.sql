with source as (
    select * from {{ source('raw', 'raw_feature_usage') }}
),
renamed as (
    select
        id as feature_usage_id
,        platform
,        feature_name
,        category
,        first_used_at
,        usage_count
,        version
,        is_active
    from source
)
select * from renamed
