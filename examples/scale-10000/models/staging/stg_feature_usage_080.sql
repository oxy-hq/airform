with source as (
    select * from {{ source('raw', 'raw_feature_usage') }}
),
renamed as (
    select
        id as feature_usage_id
,        is_active
,        platform
,        feature_name
,        usage_count
,        first_used_at
,        version
,        category
    from source
)
select * from renamed
