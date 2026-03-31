with source as (
    select * from {{ source('raw', 'raw_feature_usage') }}
),
renamed as (
    select
        id as feature_usage_id
,        user_id
,        is_active
,        first_used_at
,        category
,        platform
,        usage_count
,        feature_name
    from source
)
select * from renamed
