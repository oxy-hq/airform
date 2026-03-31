with source as (
    select * from {{ source('raw', 'raw_feature_usage') }}
),
renamed as (
    select
        id as feature_usage_id
,        usage_count
,        user_id
,        category
,        platform
,        feature_name
,        first_used_at
    from source
)
select * from renamed
