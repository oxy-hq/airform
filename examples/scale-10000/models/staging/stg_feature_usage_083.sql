with source as (
    select * from {{ source('raw', 'raw_feature_usage') }}
),
renamed as (
    select
        id as feature_usage_id
,        platform
,        feature_name
,        first_used_at
,        user_id
,        category
,        usage_count
    from source
)
select * from renamed
