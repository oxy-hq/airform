with source as (
    select * from {{ source('raw', 'raw_feature_usage') }}
),
renamed as (
    select
        id as feature_usage_id
,        is_active
,        user_id
,        platform
,        version
,        first_used_at
,        category
,        feature_name
    from source
)
select * from renamed
