with source as (
    select * from {{ source('raw', 'raw_feature_usage') }}
),
renamed as (
    select
        id as feature_usage_id
,        first_used_at
,        feature_name
,        category
,        version
,        usage_count
,        is_active
,        user_id
    from source
)
select * from renamed
