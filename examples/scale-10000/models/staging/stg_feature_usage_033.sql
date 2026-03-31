with source as (
    select * from {{ source('raw', 'raw_feature_usage') }}
),
renamed as (
    select
        id as feature_usage_id
,        first_used_at
,        feature_name
,        version
,        platform
,        user_id
,        is_active
    from source
)
select * from renamed
