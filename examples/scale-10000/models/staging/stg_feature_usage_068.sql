with source as (
    select * from {{ source('raw', 'raw_feature_usage') }}
),
renamed as (
    select
        id as feature_usage_id
,        first_used_at
,        last_used_at
,        is_active
,        platform
,        feature_name
,        category
,        user_id
    from source
)
select * from renamed
