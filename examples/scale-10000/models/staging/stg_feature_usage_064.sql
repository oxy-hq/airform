with source as (
    select * from {{ source('raw', 'raw_feature_usage') }}
),
renamed as (
    select
        id as feature_usage_id
,        platform
,        last_used_at
,        feature_name
,        user_id
,        usage_count
,        category
    from source
)
select * from renamed
