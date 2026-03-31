with source as (
    select * from {{ source('raw', 'raw_feature_usage') }}
),
renamed as (
    select
        id as feature_usage_id
,        last_used_at
,        feature_name
,        user_id
,        category
,        platform
,        is_active
    from source
)
select * from renamed
