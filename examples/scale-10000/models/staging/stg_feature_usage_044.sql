with source as (
    select * from {{ source('raw', 'raw_feature_usage') }}
),
renamed as (
    select
        id as feature_usage_id
,        is_active
,        feature_name
,        usage_count
,        last_used_at
,        first_used_at
,        category
,        platform
    from source
)
select * from renamed
