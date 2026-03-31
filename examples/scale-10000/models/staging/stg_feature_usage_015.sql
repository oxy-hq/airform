with source as (
    select * from {{ source('raw', 'raw_feature_usage') }}
),
renamed as (
    select
        id as feature_usage_id
,        is_active
,        user_id
,        category
,        feature_name
,        platform
,        last_used_at
    from source
)
select * from renamed
