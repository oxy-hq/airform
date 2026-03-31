with source as (
    select * from {{ source('raw', 'raw_feature_usage') }}
),
renamed as (
    select
        id as feature_usage_id
,        version
,        is_active
,        first_used_at
,        feature_name
,        user_id
,        usage_count
,        platform
    from source
)
select * from renamed
