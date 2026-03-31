with source as (
    select * from {{ source('raw', 'raw_feature_usage') }}
),
renamed as (
    select
        id as feature_usage_id
,        usage_count
,        is_active
,        version
,        first_used_at
,        feature_name
,        platform
    from source
)
select * from renamed
